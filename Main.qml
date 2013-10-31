import QtQuick 2.1
import QtGraphicalEffects 1.0
import ImageCanvas 1.0
import TopRoundRect 1.0
import QtWebKit 3.0
import QtMultimedia 5.0

Item {
	id: window
	
	property int titlebarHeight: 45
	property int frameRadius: 3
	property int shadowRadius: 10
	property bool isMax: false
	
	default property alias tabPages: pages.children
	property alias playPage: playPage
	property alias playlist: playlist
	property int currentTab: 0
	
	property bool showTitlebar: true
	
	function toggleMaxWindow() {
		isMax ? windowView.showNormal() : windowView.showMaximized()
		isMax ? maxButton.imageName = "image/window_max" : maxButton.imageName = "image/window_unmax"
		isMax ? shadow.visible = true : shadow.visible = false
		isMax ? frame.border.width = (shadowRadius + frameRadius) * 2 : frame.border.width = 0
		isMax ? frame.radius = frameRadius : frame.radius = 0
		/* isMax ? skinBackground.radius = frameRadius : skinBackground.radius = 0 */
		isMax ? frameBackground.radius = frameRadius : frameBackground.radius = 0
		isMax ? titlebarGradient.radius = frameRadius : titlebarGradient.radius = 0
		isMax ? frameBorder.visible = true : frameBorder.visible = false
		
		isMax = !isMax
	}

	function selectPlayPage() {
		for (var i = 0; i < tabPages.length; ++i) {
			/* Don't set opacity, otherwise 'opacity 0' widget will eat othersise widget's event */
			tabPages[i].visible = false
		}
		
		playPage.visible = true
	}
	
	function selectTabPage() {
		for (var i = 0; i < tabPages.length; ++i) {
			/* Don't set opacity, otherwise 'opacity 0' widget will eat othersise widget's event */
			tabPages[i].visible = tabButtonArea.children[i].tabIndex == currentTab
		}
		
		playPage.visible = false
	}
			
    RectangularGlow {
        id: shadow
        anchors.fill: frame
        glowRadius: shadowRadius
        spread: 0.2
        color: Qt.rgba(0, 0, 0, 0.3)
        /* color: Qt.rgba(200, 0, 0, 0.8) /\* this code just for test shadow *\/ */
        cornerRadius: frame.radius + shadowRadius
		visible: true
    }
	
    Rectangle {
        id: frame
		opacity: 1				/* frame transparent */
        color: Qt.rgba(0, 0, 0, 0)
        /* color: Qt.rgba(0, 0, 0, 1) /\* this code just for test frame *\/ */
        anchors.centerIn: parent
        radius: frameRadius
		border.width: (shadowRadius + frameRadius) * 2
		border.color: Qt.rgba(0, 0, 0, 0)
		width: window.width - border.width
		height: window.height - border.width
		
		/* Component.onCompleted: {console.log(frame.x, frame.y)} */
		
		Rectangle {
			id: frameBackground
			color: "black"
			anchors.fill: parent
			radius: frameRadius
		}
		
		/* ImageCanvas { */
		/* 	id: skinBackground */
		/* 	anchors.fill: parent */
		/* 	imageFile: "skin/4.jpg" */
		/* 	radius: frameRadius */
		/*     /\* visible: false *\/ */
		/* } */
		
    }
	
	
	Rectangle {
		id: pages
		objectName: "pages"
		anchors.top: titlebar.bottom
		anchors.bottom: frame.bottom
		anchors.left: titlebar.left
		anchors.right: titlebar.right
		color: Qt.rgba(0, 0, 0, 0)
		
		WebView {
			id: movieStorePage
			url: "http://pianku.xmp.kankan.com/moviestore_index.html"
			anchors.fill: parent
			property string name: "深度影院"
			visible: false
		}
		
		WebView {
			id: searchPage
			url: "http://search.xmp.kankan.com/lndex4xmp.shtml"
			anchors.fill: parent
			property string name: "视频搜索"
			visible: false
		}

		WebView {
			id: favouritePage
			url: "http://search.xmp.kankan.com/lndex4xmp.shtml"
			anchors.fill: parent
			property string name: "我的收藏"
			visible: false
		}
	}

	Rectangle {
		id: playPage
		anchors.top: titlebar.top
		anchors.bottom: pages.bottom
		anchors.left: pages.left
		anchors.right: pages.right
		color: Qt.rgba(0, 0, 0, 1)
		
		Row {
			anchors.fill: parent
			
			Rectangle {
				id: playlist
				height: parent.height
				width: 0
				color: Qt.rgba(10, 10, 10, 0.05)
				
				Behavior on width {
					NumberAnimation {
						duration: 100
						easing.type: Easing.OutQuint
					}
				}
			}
			
			Player {
				width: parent.width - playlist.width
				height: parent.height
				source: movie_file
				videoPreview.video.source: movie_file
				
				Component.onCompleted: {
					videoPreview.video.pause()
				}
				
				onPlaylistButtonClicked: {
					playlist.width == 0 ? playlist.width = 200 : playlist.width = 0
				}
				
				onBottomPanelShow: {
					/* titlebar.visible = true */
					showingTitlebarAnimation.restart()
				}

				onBottomPanelHide: {
					if (playPage.visible) {
						/* titlebar.visible = false */
						hidingTitlebarAnimation.restart()
					}
				}
			}
		}	
	}
		
	MouseArea {
        id: titlebar
        anchors.top: frame.top
        anchors.left: frame.left
        anchors.right: frame.right
		width: frame.width
        height: titlebarHeight
		property real lastMouseX: 0
        property real lastMouseY: 0
        onPressed: {
            lastMouseX = mouseX
            lastMouseY = mouseY
        }
        onMouseXChanged: {
			windowView.x += (mouseX - lastMouseX)
		}
        onMouseYChanged: {
			windowView.y += (mouseY - lastMouseY)
		}
		onDoubleClicked: {
			toggleMaxWindow()
		}
		
		Rectangle {
			id: titlebarBackground
			anchors.fill: parent
			color: Qt.rgba(0, 0, 0, 0)
			
			TopRoundRect {
				id: titlebarGradient
				anchors.fill: parent
				radius: frameRadius
				radialRadius: parent.width * 2
				vOffset: -parent.width
				startColor: "#0F4196"
				endColor: "#060709"
			}
			
			Image {
				id: appIcon
				source: "image/logo.png"
				anchors.left: parent.left
				anchors.verticalCenter: parent.verticalCenter
				anchors.leftMargin: 20
				visible: showTitlebar ? 1 : 0
			}

			Rectangle {
				id: tabEffect
				width: 300
				height: parent.height
				color: Qt.rgba(0, 0, 0, 0)
				
				RadialGradient {
					anchors.fill: parent
					horizontalRadius: 150
					horizontalOffset: -40
					verticalRadius: 150
					verticalOffset: -70
					
					gradient: Gradient {
						GradientStop { position: 0.0; color: Qt.rgba(33 / 255.0, 91 / 255.0, 210 / 255.0, 0.8)}
						GradientStop { position: 0.5; color: Qt.rgba(19 / 255.0, 48 / 255.0, 104 / 255.0, 0.5)}
						GradientStop { position: 0.8; color: Qt.rgba(6 / 255.0, 7 / 255.0, 9 / 255.0, 0.0)}
					}
					
				}
				
				Behavior on x {
					NumberAnimation {
						duration: 300
						easing.type: Easing.OutQuint
					}
				}
			}
			
			TabButton {
				id: playPageTab
				text: "视频播放"
				anchors.left: appIcon.right
				width: 160
				visible: showTitlebar ? 1 : 0

				onPressed: {
					tabEffect.x = x - 40
					selectPlayPage()
				}
				
				Component.onCompleted: {
					tabEffect.x = x - 40
				}
			}
				
			Row {
				id: tabButtonArea
				height: parent.height
				anchors.left: playPageTab.right
				spacing: 40
				
				Repeater {
					model: tabPages.length
					delegate: TabButton {
						text: tabPages[index].name
						tabIndex: index
						visible: showTitlebar ? 1 : 0
						
						onPressed: {
							tabEffect.x = x + width / 2 + 100
							currentTab = index
							selectTabPage()
						}
					}
				}
			}
			
			Row {
				anchors {right: parent.right}
				id: windowButtonArea
				
				ImageButton {
					id: minButton
					imageName: "image/window_min"
					onClicked: {windowView.showMinimized()}
					visible: showTitlebar ? 1 : 0
				}

				ImageButton {
					id: maxButton
					imageName: "image/window_max"
					onClicked: {toggleMaxWindow()}
					visible: showTitlebar ? 1 : 0
				}

				ImageButton {
					id: closeButton
					imageName: "image/window_close"
					onClicked: {qApp.quit()}
					visible: showTitlebar ? 1 : 0
				}
			}
		}
		
    }
	
	Rectangle {
		id: frameBorder
		anchors.fill: frame
		color: Qt.rgba(0, 0, 0, 0)
		border.color: Qt.rgba(100, 100, 100, 0.3)
		border.width: 1
		smooth: true
		radius: frameRadius
	}

	ParallelAnimation{
		id: showingTitlebarAnimation
		alwaysRunToEnd: true
		
		PropertyAnimation {
			target: titlebar
			property: "height"
			to: titlebarHeight
			duration: 100
			easing.type: Easing.OutBack
		}
		
		onRunningChanged: {
			if (!showingTitlebarAnimation.running) {
				showTitlebar = true
			}
		}
	}	

	ParallelAnimation{
		id: hidingTitlebarAnimation
		alwaysRunToEnd: true
		
		PropertyAnimation {
			target: titlebar
			property: "height"
			to: 0
			duration: 100
			easing.type: Easing.OutBack
		}
		
		onRunningChanged: {
			if (!showingTitlebarAnimation.running) {
				showTitlebar = false
			}
		}
	}	
}

