import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2

Window {
    visible: true
    width: 480
    height: 640
    minimumWidth: 480
    minimumHeight: 640
    title: "開源踩地雷"

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#2196f3"
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
                startNewGame(8, 8, 10);
            }
        }

        Button {
            text: "普通"
            onClicked: {
                startNewGame(16, 16, 40);
            }
        }

        Button {
            text: "困難"
            onClicked: {
                startNewGame(30, 16, 99);
            }
        }
    }
    Grid {
        id: table
        columns: 0
        rows: 0
        anchors.centerIn: parent
        anchors.margins: 60
        property int cellWidth: Math.min(40, parent.width / columns, parent.height / rows)
        Repeater {
            id: cell
            model: table.columns * table.rows
            Button {
                id: cellBtn
                width: table.cellWidth
                height: width
                property bool isMine
                property bool marked
                property bool opened
                property int numMineAround
                onClicked: {
                    open(index);
                }
                Behavior on opacity {
                  NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                  }
                }

                states: [
                    State {
                        when: opened && isMine
                        PropertyChanges {
                            target: highlight
                            opacity: 0.6
                            color: "#ff5722"
                        }
                        PropertyChanges {
                            target: cellBtn
                            text: "X"
                        }
                    },
                    State {
                        when: opened && !isMine
                        PropertyChanges {
                            target: highlight
                            opacity: 0
                        }
                        PropertyChanges {
                            target: cellBtn
                            text: numMineAround || ""
                        }
                    },
                    State {
                        when: marked && (!gameOver || isMine)
                        PropertyChanges {
                            target: highlight
                            opacity: 0.6
                            color: "#8bc34a"
                        }
                        PropertyChanges {
                            target: cellBtn
                            text: "✧"
                        }
                    },
                    State {
                        when: marked && gameOver && !isMine
                        PropertyChanges {
                            target: highlight
                            opacity: 0.6
                            color: "#FF9900"
                        }
                        PropertyChanges {
                            target: cellBtn
                            text: "✧"
                        }
                    }
                ]

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton | Qt.MiddleButton
                    onClicked: {
                        if (gameOver) return;
                        if (mouse.button == Qt.RightButton) {
                            if(parent.marked) {
                                parent.marked = false;
                                numMineLeft++;
                            }
                            else if(!parent.opened) {
                                parent.marked = true;
                                numMineLeft--;
                            }
                        }
                        else{
                            if(!parent.opened) return;
                            var count = 0;
                            var x = Math.floor(index / table.columns), y = index % table.columns;
                            for(var dx = -1; dx <= 1; ++dx) {
                                for(var dy = -1; dy <= 1; ++dy) {
                                    var shiftedIndex = index + dx * table.columns + dy;
                                    if (0 <= x + dx && x + dx < table.rows && 0 <= y + dy && y + dy < table.columns && cell.itemAt(shiftedIndex).marked) {
                                        count++;
                                    }
                                }
                            }
                            if (parent.numMineAround == count) openAround(index);
                        }
                    }
                }
                Rectangle {
                    id: highlight
                    anchors.fill: parent
                    opacity: 0.4
                    radius: 5
                    color: "#3f51b5"
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
    Text {
        anchors.right: parent.right
        anchors.verticalCenter: newGame.verticalCenter
        anchors.margins: 20
        text: numMineLeft
    }

    property bool gameOver
    property int numMine
    property int numMineLeft

    function startNewGame(col, row, num_mine) {
        table.columns = col;
        table.rows = row;
        numMine = num_mine;
        numMineLeft = num_mine;
        rearrangeMine();
        gameOver = false;
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
        for(var k = 0, pos; k < numMine; ++k) {
            do {
                pos = Math.floor(Math.random() * cell.model);
            } while (cell.itemAt(pos).isMine);
            cell.itemAt(pos).isMine = true;
            // calc mines around
            var x = Math.floor(pos / table.columns), y = pos % table.columns;
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
        if (gameOver || cell.itemAt(index).opened || cell.itemAt(index).marked) return;
        cell.itemAt(index).opened = true;
        if (cell.itemAt(index).isMine) explode();
        else if (!cell.itemAt(index).numMineAround) openAround(index);
    }

    function openAround(index) {
        var x = Math.floor(index / table.columns), y = index % table.columns;
        for(var dx = -1; dx <= 1; ++dx) {
            for(var dy = -1; dy <= 1; ++dy) {
                var shiftedIndex = index + dx * table.columns + dy;
                if (0 <= x + dx && x + dx < table.rows && 0 <= y + dy && y + dy < table.columns) {
                    open(shiftedIndex);
                }
            }
        }
    }

    function explode() {
        // open all mines
        for(var i = 0; i < table.rows; ++i) {
            for(var j = 0; j < table.columns; ++j) {
                var index = i * table.columns + j;
                if (cell.itemAt(index).isMine) open(index);
            }
        }
        gameOver = true;
    }

    Component.onCompleted: {
        rearrangeMine();
    }
}
