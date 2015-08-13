import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2

Window {
    visible: true
    width: 480
    height: 480
    title: "開源踩地雷"

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#33b5e5"
        radius: 20
    }

    Row {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 8
        anchors.margins: 8
        Button {
            text: "容易"
            onClicked: {
                table.columns = 8
                table.rows = 8
                table.numMine = 10
                rearrangeMine()
            }
        }

        Button {
            text: "普通"
            onClicked: {
                table.columns = 16
                table.rows = 16
                table.numMine = 40
                rearrangeMine()
            }
        }

        Button {
            text: "困難"
            onClicked: {
                table.columns = 30
                table.rows = 16
                table.numMine = 99
                rearrangeMine()
            }
        }
    }

    Grid {
        id: table
        columns: 16
        rows: columns
        anchors.centerIn: parent
        property int numMine

        Repeater {
            id: cell
            model: table.columns * table.rows
            Button {
                width: 360 / table.rows
                height: 360 / table.columns
                text: ""
                property bool isMine: false
                property bool flag: false
                property bool opened: false
                property int numMineAround: 0
                onClicked: {
                    if (!flag) open(index);
                }

                Rectangle {
                    id: highlight
                    anchors.fill: parent
                    color: "red"
                    opacity: (parent.isMine && parent.opened) ? 0.8 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 1000
                            easing.type: Easing.OutBounce
                        }
                    }
                }
            }
        }
    }

    function rearrangeMine() {
        var shift = [-table.columns-1, -table.columns, -table.columns+1,
                     -1, 1, table.columns-1, table.columns, table.columns+1]
        // planting mines
        for(var i = 0, j; i < table.numMine; ++i) {
            do {
                j = Math.floor(Math.random() * cell.model);
            } while (cell.itemAt(j).isMine);
            cell.itemAt(j).isMine = true;
        }
        // calculating mines around
        /*for(var i = 0; i < table.rows; ++i) {
            for(var j = 0; j < table.columns; ++j) {
                var index = i * table.columns + j;
                if(i && j)
                    cell.itemAt(index).numMineAround += cell.itemAt(index + shift[0]).isMine // upper left
                if(i)
                    cell.itemAt(index).numMineAround += cell.itemAt(index + shift[1]).isMine // upper middle
                if(i && j < table.columns - 1)
                    cell.itemAt(index).numMineAround += cell.itemAt(index + shift[2]).isMine // upper right
                if(j)
                    cell.itemAt(index).numMineAround += cell.itemAt(index + shift[3]).isMine // middle left
                if(j < table.columns - 1)
                    cell.itemAt(index).numMineAround += cell.itemAt(index + shift[4]).isMine // middle right
                if(i < table.rows - 1 && j)
                    cell.itemAt(index).numMineAround += cell.itemAt(index + shift[5]).isMine // lower left
                if(i < table.rows - 1)
                    cell.itemAt(index).numMineAround += cell.itemAt(index + shift[6]).isMine // lower middle
                if(i < table.rows - 1 && j < table.columns - 1)
                    cell.itemAt(index).numMineAround += cell.itemAt(index + shift[7]).isMine // lower right
            }
        }*/
    }

    /*property variant shift: [-table.columns-1, -table.columns, -table.columns+1,
    -1, 1, table.columns-1, table.columns, table.columns+1]*/

    function open(index) {
        var shift = [-table.columns-1, -table.columns, -table.columns+1,
                     -1, 1, table.columns-1, table.columns, table.columns+1]
        cell.itemAt(index).opened = true;
        if (cell.itemAt(index).isMine) {
            cell.itemAt(index).text = 'X'
            //animation.start()
        }
        else /*if (cell.itemAt(index).numMineAround > 0)*/ {
            cell.itemAt(index).text = cell.itemAt(index).numMineAround
        }
        /*else {
            var i = index / table.rows;
            var j = index % table.columns;
            if(i && j &&
                    !cell.itemAt(index + shift[0]).opened) open(index + shift[0]) // upper left
            if(i &&
                    !cell.itemAt(index + shift[1]).opened) open(index + shift[1]) // upper middle
            if(i && j < table.columns - 1 &&
                    !cell.itemAt(index + shift[2]).opened) open(index + shift[2]) // upper right
            if(j &&
                    !cell.itemAt(index + shift[3]).opened) open(index + shift[3]) // middle left
            if(j < table.columns - 1 &&
                    !cell.itemAt(index + shift[4]).opened) open(index + shift[4]) // middle right
            if(i < table.rows - 1 && j &&
                    !cell.itemAt(index + shift[5]).opened) open(index + shift[5])// lower left
            if(i < table.rows - 1 &&
                    !cell.itemAt(index + shift[6]).opened) open(index + shift[6]) // lower middle
            if(i < table.rows - 1 && j < table.columns - 1 &&
                    !cell.itemAt(index + shift[7]).opened) open(index + shift[7]) // lower right
        }*/
    }

    Component.onCompleted: {
        rearrangeMine()
    }
}
