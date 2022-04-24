// main.qml
import QtQuick 2.6
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0

MouseArea {
  id: root

  Layout.minimumWidth: PlasmaCore.Units.gridUnit * 30

  Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
  Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground | PlasmaCore.Types.ConfigurableBackground

  property bool pendingRequest: false
  property int messageIndex: 0

  PlasmaComponents.Label {
    id: messageLabel
    text: "..."
    anchors.fill: parent
    horizontalAlignment: Text.AlignHCenter
  }

  onClicked: switchLabel()

  function switchLabel() {
    messageIndex = messageIndex + 1
  }

  function updateWidth() {
    root.Layout.minimumWidth = PlasmaCore.Units.gridUnit * (
      Math.ceil(
        messageLabel.text.length / Math.max(plasmoid.configuration.widthFactor, 1)
      )
    );
  }

  function updateMessage() {
    if(pendingRequest) return;

    if(plasmoid.configuration.serverEndpoint === "") {
      messageLabel.text = '?';
      updateWidth();
      return;
    }

    pendingRequest = true;

    const request = new XMLHttpRequest();

    request.onreadystatechange = () => {
      if(request.readyState !== XMLHttpRequest.DONE) return;

      try {
        if(request.status == 200) {
          const result = JSON.parse(request.responseText);

          if(!result.messages[messageIndex]) messageIndex = 0;

          if(result.messages[messageIndex]) {
            messageLabel.text = result.messages[messageIndex];
          } else {
            messageLabel.text = '...';
          }
        } else {
          messageLabel.text = 'offline'
        }

        updateWidth();
      } catch (_) {}

      pendingRequest = false;
    }

    request.open('GET', plasmoid.configuration.serverEndpoint, true);
    request.send();
  }

  Component.onCompleted: {
    updateWidth();
    updateMessage();
  }

  Timer {
    interval: Math.max(plasmoid.configuration.pullingInterval * 1000, 1)
    running: true
    repeat: true
    onTriggered: {
      updateMessage()
    }
  }
}
