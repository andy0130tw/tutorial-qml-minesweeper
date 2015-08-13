import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2

Window {
    visible: true
    width: 480
    height: width + 60
    minimumWidth: 480
    title: "開源踩地雷"

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#33b5e5"
        radius: 20
    }

    Row {
        id: newGame
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
                startNewGame(16, 16, 40)
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
        columns: 0
        rows: 0
        anchors.centerIn: parent
        property int numMine
        property int cellWidth: 30//Math.min()
        Repeater {
            id: cell
            model: table.columns * table.rows
            Button {
                width: table.cellWidth
                height: width
                text: opened ? (isMine ? "X" : numMineAround) : (marked ? "+" : "");
                property bool isMine: false
                property bool marked: false
                property bool opened: false
                property int numMineAround: 0
                onClicked: {
                    if (!marked) open(index);
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    onClicked: {
                        parent.marked = !parent.marked;
                    }
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

    function startNewGame(col, row, num_mine) {
        table.columns = col;
        table.rows = row;
        table.numMine = num_mine;
        rearrangeMine();
    }

    function rearrangeMine() {
        // init
        var ary = [];
        for(var i = 0; i < table.rows; ++i) {
            ary[i] = [];
            for(var j = 0; j < table.columns; ++j) {
                ary[i][j] = 0;
                var index = i * table.columns + j;
                cell.itemAt(index).numMineAround = 0;
                cell.itemAt(index).opened = false;
                cell.itemAt(index).marked = false;
                cell.itemAt(index).isMine = false;
            }
        }
        // plant mines
        for(var k = 0, index; k < table.numMine; ++k) {
            do {
                index = Math.floor(Math.random() * cell.model);
            } while (cell.itemAt(index).isMine);
            cell.itemAt(index).isMine = true;
            // calc mines around
            var x = Math.floor(index / table.rows), y = index % table.columns;
            ary[x][y] = -65536;
            for(var dx = -1; dx <= 1; ++dx) {
                for(var dy = -1; dy <= 1; ++dy) {
                    if(ary[x + dx] === undefined) break;
                    if(ary[x + dx][y + dy] === undefined) continue;
                    ary[x + dx][y + dy] += 1;
                }
            }
        }
        // update cells properties
        for(var i = 0; i < table.rows; ++i) {
            for(var j = 0; j < table.columns; ++j) {
                cell.itemAt(i * table.columns + j).numMineAround = ary[i][j];
            }
        }
    }

    function open(index) {
        var x = Math.floor(index / table.rows), y = index % table.columns;
        if(cell.itemAt(index).opened || cell.itemAt(index).marked) return;
        else cell.itemAt(index).opened = true;
        if (!cell.itemAt(index).numMineAround) {
            // no mines around; open cells around automatically
            for(var dx = -1; dx <= 1; ++dx) {
                for(var dy = -1; dy <= 1; ++dy) {
                    var shiftedIndex = (x + dx) * table.columns + (y + dy);
                    if(0 <= x + dx && x + dx < table.rows && 0 <= y + dy && y + dy < table.columns) open(shiftedIndex);
                }
            }
        }
    }

    Component.onCompleted: {
        rearrangeMine();
    }
}
