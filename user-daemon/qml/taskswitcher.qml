import QtQuick 2.1
import Sailfish.Silica 1.0
import QtSensors 5.0 as Sensors

Item
{
    id: root

    width: Screen.width
    height: Screen.height
    rotation: 0

    property int currentApp: viewHelper.currentApp
    property int numberOfApps: viewHelper.numberOfApps

    onCurrentAppChanged:
    {
        appName.text = appsModel.get(viewHelper.currentApp).name
    }

    onNumberOfAppsChanged:
    {
        updateAppsModel()
        appName.text = appsModel.get(viewHelper.currentApp).name

        viewHelper.setTouchRegion(Qt.rect(taskSwitchBackground.x,
                                          taskSwitchBackground.y,
                                          taskSwitchBackground.width,
                                          taskSwitchBackground.height))
    }

    Sensors.OrientationSensor
    {
        id: rotationSensor
        active: viewHelper.visible
        property int angle: reading.orientation
        onAngleChanged:
        {
            if (reading.orientation === 3) /* Landscape inverted */
                root.rotation = 180
            else if (reading.orientation === 4) /* Landscape */
                root.rotation = 0
        }
    }

    function updateAppsModel()
    {
        var i
        var tmp = viewHelper.getCurrentApps()

        appsModel.clear()

        for (i=0 ; i<tmp.length; i++)
        {
            appsModel.append( { "iconId": tmp[i]["iconId"],
                                "name":   tmp[i]["name"] } )
        }
    }

    ListModel
    {
        id: appsModel
    }

    Rectangle
    {
        anchors.fill: parent
        color: "black"
        opacity: 0.5
    }

    Rectangle
    {
        id: taskSwitchBackground
        anchors.centerIn: root
        anchors.horizontalCenterOffset: Theme.paddingLarge
        color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
        radius: Theme.paddingSmall
        width: Theme.itemSizeLarge * taskSwitchGrid.rows + 2 * Theme.paddingLarge
        height: Theme.itemSizeLarge * taskSwitchGrid.columns + Theme.paddingLarge
        clip: true
    }

    Label
    {
        id: appName
        rotation: 90
        anchors.centerIn: taskSwitchBackground
        anchors.horizontalCenterOffset: Theme.paddingSmall + (Theme.itemSizeLarge * (taskSwitchGrid.rows/2))
        text: "???"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.primaryColor
    }

    Grid
    {
        id: taskSwitchGrid
        anchors.centerIn: taskSwitchBackground
        anchors.horizontalCenterOffset: -Theme.paddingLarge/2
        rotation: 90
        property int i : appsModel.count
        columns: (i<6) ? i : ((i<12) ? ((i%2 == 0) ? i/2 : i/2 +1) : ((i%3 == 0) ? i/3 : i/3 +1))
        rows: (i<6) ? 1 : ((i<12) ? 2 : 3)

        Repeater
        {
            id: appIconRepeater
            model: appsModel

            Item
            {
                width: Theme.itemSizeLarge
                height: Theme.itemSizeLarge

                Rectangle
                {
                    id: appIconBackground
                    anchors.fill: parent
                    color: viewHelper.currentApp === index ? Theme.highlightColor : "transparent"
                    opacity: 0.7
                    radius: Theme.paddingSmall
                }

                Image
                {
                    id: appIcon
                    anchors.centerIn: appIconBackground
                    source: iconId
                    property real size: Theme.iconSizeLauncher

                    sourceSize.width: size
                    sourceSize.height: size
                    width: size
                    height: size
                }

                MouseArea
                {
                    anchors.fill: parent
                    onPressed: viewHelper.setCurrentApp(index)
                    onClicked: viewHelper.launchApplication(index)
                }
            }
        }
    }
}
