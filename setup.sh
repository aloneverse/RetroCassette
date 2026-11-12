
#!/bin/bash
echo "📻 Creating Retro Dark Cassette Widget Project..."

# Folders banana
mkdir -p .github/workflows
mkdir -p app/src/main/res/xml
mkdir -p app/src/main/res/layout
mkdir -p app/src/main/res/drawable
mkdir -p app/src/main/java/com/retro/cassettewidget

# 1. GitHub Actions Workflow (APK Builder)
cat << 'EOF' > .github/workflows/build.yml
name: Build Retro Widget APK
on:
  push:
    branches: [ "main", "master" ]
  workflow_dispatch:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
      - uses: android-actions/setup-android@v3
      - name: Run Auto Setup & Build APK
        run: |
          chmod +x setup.sh
          ./setup.sh
          gradle wrapper --gradle-version 8.5
          chmod +x gradlew
          ./gradlew assembleDebug
      - uses: actions/upload-artifact@v4
        with:
          name: Retro-Cassette-Widget-APK
          path: app/build/outputs/apk/debug/app-debug.apk
EOF

# 2. Root Gradle Files
cat << 'EOF' > build.gradle
plugins {
    id 'com.android.application' version '8.2.2' apply false
    id 'org.jetbrains.kotlin.android' version '1.9.22' apply false
}
EOF

cat << 'EOF' > settings.gradle
pluginManagement {
    repositories { google(); mavenCentral(); gradlePluginPortal() }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories { google(); mavenCentral() }
}
rootProject.name = "RetroCassetteWidget"
include ':app'
EOF

# 3. App Gradle
cat << 'EOF' > app/build.gradle
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
}
android {
    namespace 'com.retro.cassettewidget'
    compileSdk 34
    defaultConfig {
        applicationId "com.retro.cassettewidget"
        minSdk 26
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }
    buildTypes {
        release { minifyEnabled false }
    }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = '17' }
}
dependencies {
    implementation 'androidx.core:core-ktx:1.12.0'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.11.0'
}
EOF

# 4. AndroidManifest.xml
cat << 'EOF' > app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.retro.cassettewidget">
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <application
        android:allowBackup="true"
        android:label="Retro Cassette"
        android:supportsRtl="true"
        android:theme="@style/Theme.MaterialComponents.DayNight.NoActionBar">
        <activity android:name=".MainActivity" android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        <receiver android:name=".CassetteWidgetProvider" android:exported="true" android:label="Retro Walkman Cassette">
            <intent-filter>
                <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
                <action android:name="com.retro.cassettewidget.ACTION_PLAY_PAUSE" />
                <action android:name="com.retro.cassettewidget.ACTION_NEXT" />
                <action android:name="com.retro.cassettewidget.ACTION_OPEN_APP" />
            </intent-filter>
            <meta-data android:name="android.appwidget.provider" android:resource="@xml/cassette_widget_info" />
        </receiver>
        <service android:name=".MusicNotificationListener" android:exported="true" android:label="Retro Cassette Sync"
            android:permission="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE">
            <intent-filter>
                <action android:name="android.service.notification.NotificationListenerService" />
            </intent-filter>
        </service>
    </application>
</manifest>
EOF

# 5. Widget Info XML
cat << 'EOF' > app/src/main/res/xml/cassette_widget_info.xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="250dp"
    android:minHeight="110dp"
    android:targetCellWidth="4"
    android:targetCellHeight="2"
    android:updatePeriodMillis="86400000"
    android:initialLayout="@layout/widget_cassette"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen" />
EOF

# 6. Drawables (Dark Retro Theme)
cat << 'EOF' > app/src/main/res/drawable/cassette_body_bg.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <gradient android:angle="135" android:startColor="#1A1715" android:endColor="#0B0A09" />
    <corners android:radius="16dp" />
    <stroke android:width="1.5dp" android:color="#38312B" />
</shape>
EOF

cat << 'EOF' > app/src/main/res/drawable/cassette_label_bg.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#241F1C" />
    <corners android:radius="8dp" />
    <stroke android:width="1dp" android:color="#8C5828" />
</shape>
EOF

cat << 'EOF' > app/src/main/res/drawable/cassette_window_bg.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#12100E" />
    <corners android:radius="10dp" />
    <stroke android:width="1.5dp" android:color="#5C5349" />
</shape>
EOF

cat << 'EOF' > app/src/main/res/drawable/retro_button_bg.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#3D3834" />
    <corners android:radius="6dp" />
    <stroke android:width="1dp" android:color="#6E655D" />
</shape>
EOF

cat << 'EOF' > app/src/main/res/drawable/retro_button_accent_bg.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#C8641E" />
    <corners android:radius="6dp" />
    <stroke android:width="1dp" android:color="#E5A93C" />
</shape>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_cassette_reel.xml
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="48dp" android:height="48dp" android:viewportWidth="48" android:viewportHeight="48">
    <path android:fillColor="#3A281E" android:pathData="M24,2 A22,22 0 1,1 23.9,2 Z" />
    <path android:fillColor="#F4ECD8" android:pathData="M24,10 A14,14 0 1,1 23.9,10 Z" />
    <path android:fillColor="#12100E" android:pathData="M24,18 A6,6 0 1,1 23.9,18 Z" />
    <path android:fillColor="#E87A24" android:pathData="M22.5,10 h3 v7 h-3 z M22.5,31 h3 v7 h-3 z M10,22.5 h7 v3 h-7 z M31,22.5 h7 v3 h-7 z" />
</vector>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_default_album.xml
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="48dp" android:height="48dp" android:viewportWidth="48" android:viewportHeight="48">
    <path android:fillColor="#181512" android:pathData="M0,0 h48 v48 h-48 z" />
    <path android:fillColor="#38312B" android:pathData="M24,6 A18,18 0 1,1 23.9,6 Z" />
    <path android:fillColor="#C8641E" android:pathData="M24,18 A6,6 0 1,1 23.9,18 Z" />
    <path android:fillColor="#0B0A09" android:pathData="M24,22 A2,2 0 1,1 23.9,22 Z" />
</vector>
EOF

# 7. Widget Layout (Dark Retro + Album Art + Reels + Buttons)
cat << 'EOF' > app/src/main/res/layout/widget_cassette.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/widget_root"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@drawable/cassette_body_bg"
    android:orientation="vertical"
    android:padding="10dp">

    <LinearLayout
        android:id="@+id/label_container"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:background="@drawable/cassette_label_bg"
        android:gravity="center_vertical"
        android:orientation="horizontal"
        android:paddingHorizontal="8dp"
        android:paddingVertical="6dp">

        <ImageView
            android:id="@+id/iv_album_art"
            android:layout_width="44dp"
            android:layout_height="44dp"
            android:layout_marginEnd="10dp"
            android:background="#0D0B0A"
            android:padding="1dp"
            android:scaleType="centerCrop"
            android:src="@drawable/ic_default_album" />

        <LinearLayout
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:orientation="vertical">

            <TextView
                android:id="@+id/tv_side_tag"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:fontFamily="monospace"
                android:text="SIDE A  •  CHROME 90 DARK"
                android:textColor="#E5A93C"
                android:textSize="8sp"
                android:textStyle="bold" />

            <TextView
                android:id="@+id/tv_song_title"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:ellipsize="marquee"
                android:fontFamily="monospace"
                android:singleLine="true"
                android:text="TAP TO OPEN MUSIC PLAYER"
                android:textColor="#F2E6D8"
                android:textSize="12sp"
                android:textStyle="bold" />

            <TextView
                android:id="@+id/tv_artist_name"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:ellipsize="end"
                android:fontFamily="monospace"
                android:singleLine="true"
                android:text="Retro Dark Edition"
                android:textColor="#9E9184"
                android:textSize="10sp" />
        </LinearLayout>
    </LinearLayout>

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="44dp"
        android:layout_marginTop="8dp"
        android:background="@drawable/cassette_window_bg"
        android:gravity="center"
        android:orientation="horizontal"
        android:paddingHorizontal="16dp">

        <ImageView
            android:id="@+id/iv_reel_left"
            android:layout_width="34dp"
            android:layout_height="34dp"
            android:src="@drawable/ic_cassette_reel" />

        <TextView
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:fontFamily="monospace"
            android:gravity="center"
            android:text="██ 90 MIN ██"
            android:textColor="#6E655D"
            android:textSize="9sp" />

        <ImageView
            android:id="@+id/iv_reel_right"
            android:layout_width="34dp"
            android:layout_height="34dp"
            android:src="@drawable/ic_cassette_reel" />
    </LinearLayout>

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="8dp"
        android:gravity="center"
        android:orientation="horizontal">

        <Button
            android:id="@+id/btn_open_app"
            android:layout_width="0dp"
            android:layout_height="30dp"
            android:layout_marginEnd="6dp"
            android:layout_weight="1.2"
            android:background="@drawable/retro_button_bg"
            android:fontFamily="monospace"
            android:padding="0dp"
            android:text="OPEN APP"
            android:textColor="#F2E6D8"
            android:textSize="10sp" />

        <Button
            android:id="@+id/btn_play_pause"
            android:layout_width="0dp"
            android:layout_height="30dp"
            android:layout_marginEnd="6dp"
            android:layout_weight="1"
            android:background="@drawable/retro_button_accent_bg"
            android:fontFamily="monospace"
            android:padding="0dp"
            android:text="⏯ PLAY"
            android:textColor="#12100E"
            android:textSize="10sp"
            android:textStyle="bold" />

        <Button
            android:id="@+id/btn_next"
            android:layout_width="0dp"
            android:layout_height="30dp"
            android:layout_weight="1"
            android:background="@drawable/retro_button_bg"
            android:fontFamily="monospace"
            android:padding="0dp"
            android:text="⏭ NEXT"
            android:textColor="#F2E6D8"
            android:textSize="10sp" />
    </LinearLayout>
</LinearLayout>
EOF

# 8. Kotlin Files
cat << 'EOF' > app/src/main/java/com/retro/cassettewidget/MainActivity.kt
package com.retro.cassettewidget

import android.content.ComponentName
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.provider.Settings
import android.text.TextUtils
import android.view.Gravity
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    private lateinit var statusText: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#141210"))
            setPadding(48, 48, 48, 48)
        }
        val title = TextView(this).apply {
            text = "📻 RETRO DARK CASSETTE"
            textSize = 22f
            setTextColor(Color.parseColor("#E5A93C"))
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 24)
        }
        val desc = TextView(this).apply {
            text = "Gane ka album photo aur ghumti hui cassette chalane ke liye Notification Access allow karein.\n\nPhir Home Screen par jaakar 'Retro Walkman Cassette' widget lagayein!"
            textSize = 14f
            setTextColor(Color.parseColor("#F2E6D8"))
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 36)
        }
        statusText = TextView(this).apply {
            textSize = 14f
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 24)
        }
        val permButton = Button(this).apply {
            text = "1. GRANT MUSIC SYNC PERMISSION"
            setBackgroundColor(Color.parseColor("#C8641E"))
            setTextColor(Color.parseColor("#141210"))
            setOnClickListener { startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)) }
        }
        layout.addView(title); layout.addView(desc); layout.addView(statusText); layout.addView(permButton)
        setContentView(layout)
    }

    override fun onResume() {
        super.onResume()
        if (isNotificationServiceEnabled()) {
            statusText.text = "✅ Connected! Ab Home Screen par Widget lagayein."
            statusText.setTextColor(Color.parseColor("#6BCB77"))
        } else {
            statusText.text = "⚠️ Permission Pending"
            statusText.setTextColor(Color.parseColor("#E5A93C"))
        }
    }

    private fun isNotificationServiceEnabled(): Boolean {
        val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
        return !TextUtils.isEmpty(flat) && flat.split(":").any {
            ComponentName.unflattenFromString(it)?.packageName == packageName
        }
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/retro/cassettewidget/MusicNotificationListener.kt
package com.retro.cassettewidget

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Matrix
import android.media.MediaMetadata
import android.media.session.MediaController
import android.media.session.MediaSessionManager
import android.media.session.PlaybackState
import android.os.Handler
import android.os.Looper
import android.service.notification.NotificationListenerService
import android.widget.RemoteViews
import androidx.core.content.ContextCompat

class MusicNotificationListener : NotificationListenerService() {
    companion object {
        var activeController: MediaController? = null
        var currentTitle: String = "NO CASSETTE INSERTED"
        var currentArtist: String = "Tap to open music app"
        var currentAlbumArt: Bitmap? = null
        var isPlaying: Boolean = false
        var currentPackage: String? = null
    }

    private lateinit var sessionManager: MediaSessionManager
    private val handler = Handler(Looper.getMainLooper())
    private var reelAngle = 0f

    private val spinRunnable = object : Runnable {
        override fun run() {
            if (isPlaying) {
                reelAngle = (reelAngle + 15f) % 360f
                updateAllWidgets()
                handler.postDelayed(this, 120)
            }
        }
    }

    private val sessionsListener = MediaSessionManager.OnActiveSessionsChangedListener { controllers ->
        attachToActiveSession(controllers)
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        sessionManager = getSystemService(Context.MEDIA_SESSION_SERVICE) as MediaSessionManager
        val component = ComponentName(this, MusicNotificationListener::class.java)
        try {
            sessionManager.addOnActiveSessionsChangedListener(sessionsListener, component)
            attachToActiveSession(sessionManager.getActiveSessions(component))
        } catch (e: SecurityException) { e.printStackTrace() }
    }

    private fun attachToActiveSession(controllers: List<MediaController>?) {
        if (controllers.isNullOrEmpty()) return
        val controller = controllers[0]
        activeController = controller
        currentPackage = controller.packageName
        updateMetadata(controller.metadata)
        updatePlaybackState(controller.playbackState)
        controller.registerCallback(object : MediaController.Callback() {
            override fun onMetadataChanged(metadata: MediaMetadata?) { updateMetadata(metadata) }
            override fun onPlaybackStateChanged(state: PlaybackState?) { updatePlaybackState(state) }
        })
    }

    private fun updateMetadata(metadata: MediaMetadata?) {
        currentTitle = metadata?.getString(MediaMetadata.METADATA_KEY_TITLE) ?: "UNKNOWN TRACK"
        currentArtist = metadata?.getString(MediaMetadata.METADATA_KEY_ARTIST) ?: "Retro Stereo"
        val rawArt = metadata?.getBitmap(MediaMetadata.METADATA_KEY_ALBUM_ART) ?: metadata?.getBitmap(MediaMetadata.METADATA_KEY_ART)
        currentAlbumArt = if (rawArt != null) Bitmap.createScaledBitmap(rawArt, 140, 140, true) else null
        updateAllWidgets()
    }

    private fun updatePlaybackState(state: PlaybackState?) {
        val playingNow = state?.state == PlaybackState.STATE_PLAYING
        if (playingNow && !isPlaying) {
            isPlaying = true
            handler.removeCallbacks(spinRunnable)
            handler.post(spinRunnable)
        } else if (!playingNow) {
            isPlaying = false
            handler.removeCallbacks(spinRunnable)
            updateAllWidgets()
        }
    }

    private fun updateAll
