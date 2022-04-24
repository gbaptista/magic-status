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
  property int labelIndex: 0

  PlasmaComponents.Label {
    id: myLabel
    text: "..."
    anchors.fill: parent
    horizontalAlignment: Text.AlignHCenter
  }

  onClicked: switchLabel()

  function switchLabel() {
    labelIndex = labelIndex + 1
  }

  function updateWidth() {
    root.Layout.minimumWidth = PlasmaCore.Units.gridUnit * (
      Math.ceil(myLabel.text.length / plasmoid.configuration.widthFactor)
    );
  }

  function updateLabel() {
    if(pendingRequest) return;

    if(plasmoid.configuration.serverEndpoint === "") {
      myLabel.text = '?';
      updateWidth();
      return;
    }

    pendingRequest = true;

    const request = new XMLHttpRequest();

    request.onreadystatechange = () => {
      if(request.readyState !== XMLHttpRequest.DONE) return;

      if(request.status == 200) {
        const result = JSON.parse(request.responseText);

        if(!result.labels[labelIndex]) labelIndex = 0;

        if(result.labels[labelIndex]) {
          myLabel.text = result.labels[labelIndex];
        } else {
          myLabel.text = '...';
        }
      } else {
        myLabel.text = 'offline'
      }

      updateWidth();

      pendingRequest = false;
    }

    request.open('GET', plasmoid.configuration.serverEndpoint, true);
    request.send();
  }

  Component.onCompleted: {
    updateLabel();
  }

  Timer {
    interval: 1
    running: true
    repeat: true
    onTriggered: {
      updateLabel()
    }
  }
}
