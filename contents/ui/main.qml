// main.qml
import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15
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
    anchors.bottomMargin: 0
  }

  ProgressBar {
    id: progressBar
    value: 0.5
    height: 2
    visible: false
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 1
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

  function buildMessage(inputMessage) {
    const message = {
      label: {
        text: '',
        color: PlasmaCore.ColorScope.textColor
      },
      progress: { value: 0.1, visible: false }
    };

    if (typeof inputMessage === 'string' || inputMessage instanceof String) {
      message.label.text = inputMessage;
      return message;
    }

    if(inputMessage.label) {
      if(inputMessage.label.text) message.label.text = inputMessage.label.text;
      if(inputMessage.label.color) message.label.color = inputMessage.label.color;
    }

    if(inputMessage.progress) {
      if(inputMessage.progress.value) {
        message.progress.visible = true;
        message.progress.value = inputMessage.progress.value;
      }
    }

    return message;
  }

  function applyMessage(inputMessage) {
    const message = buildMessage(inputMessage);

    messageLabel.text = message.label.text;
    messageLabel.color = message.label.color;

    progressBar.visible = message.progress.visible;
    progressBar.value = message.progress.value;

    if(message.progress.visible) {
      messageLabel.anchors.bottomMargin = 5;
    } else {
      messageLabel.anchors.bottomMargin = 0;
    }

    updateWidth();
  }

  function updateMessage() {
    if(pendingRequest) return;

    if(plasmoid.configuration.serverEndpoint === "") {
      applyMessage('?');
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
            applyMessage(result.messages[messageIndex]);
          } else {
            applyMessage('...');
          }
        } else {
          applyMessage('offline');
        }
      } catch (_) {}

      pendingRequest = false;
    }

    request.open('GET', plasmoid.configuration.serverEndpoint, true);
    request.send();
  }

  Component.onCompleted: {
    applyMessage('...');
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
