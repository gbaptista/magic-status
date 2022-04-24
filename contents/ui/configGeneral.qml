import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Controls 1.0 as QtControls1
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
  id: configPage

  signal configurationChanged

  property alias cfg_serverEndpoint: serverEndpoint.text
  property alias cfg_widthFactor: widthFactor.value

  TextField {
    id: serverEndpoint
    Kirigami.FormData.label: i18n("Server Endpoint:")
    placeholderText: i18n("http://localhost:5000")
  }

  QtControls1.SpinBox {
    id: widthFactor
    Kirigami.FormData.label: i18n("Width Factor:")
    decimals: 1
  }
}
