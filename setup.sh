set -e
mkdir -p app/src/main/java/com/retro/musicwidget app/src/main/res/xml app/src/main/res/drawable app/src/main/res/layout
cat > settings.gradle << 'XEOF'
pluginManagement { repositories { google(); mavenCentral(); gradlePluginPortal() } }
dependencyResolutionManagement { repositories { google(); mavenCentral() } }
rootProject.name = "RetroMusicWidget"
include ':app'
XEOF
cat > build.gradle << 'XEOF'
plugins { id 'com.android.application' version '8.5.2' apply false }
XEOF
cat > gradle.properties << 'XEOF'
org.gradle.jvmargs=-Xmx2g
android.useAndroidX=false
XEOF
cat > app/build.gradle << 'XEOF'
plugins { id 'com.android.application' }
android {
    namespace 'com.retro.musicwidget'
    compileSdk 34
    defaultConfig {
        applicationId 'com.retro.musicwidget'
        minSdk 26
        targetSdk 34
        versionCode 1
        versionName '1.0'
    }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
}
XEOF
cat > app/src/main/AndroidManifest.xml << 'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <queries>
        <intent>
            <action android:name="android.intent.action.MAIN"/>
            <category android:name="android.intent.category.LAUNCHER"/>
        </intent>
    </queries>
    <application android:label="Retro Music Widget" android:icon="@drawable/cassette_body">
        <activity android:name=".MainActivity" android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <receiver android:name=".MusicWidget" android:exported="true">
            <intent-filter>
                <action android:name="android.appwidget.action.APPWIDGET_UPDATE"/>
            </intent-filter>
            <meta-data android:name="android.appwidget.provider" android:resource="@xml/widget_info"/>
        </receiver>
        <service android:name=".NotifListener" android:exported="true"
            android:permission="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE">
            <intent-filter>
                <action android:name="android.service.notification.NotificationListenerService"/>
            </intent-filter>
        </service>
    </application>
</manifest>
XEOF
cat > app/src/main/java/com/retro/musicwidget/MainActivity.java << 'XEOF'
package com.retro.musicwidget;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Typeface;
import android.os.Bundle;
import android.provider.Settings;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        LinearLayout l = new LinearLayout(this);
        l.setOrientation(LinearLayout.VERTICAL);
        l.setPadding(48, 120, 48, 48);
        l.setBackgroundColor(0xFF1E1510);
        TextView t = new TextView(this);
        t.setTextColor(0xFFF3E6C8);
        t.setTextSize(16);
        t.setTypeface(Typeface.MONOSPACE);
        t.setText("RETRO MUSIC WIDGET\n\n1. Tap the button below and allow access for this app.\n\n2. Long-press your home screen > Widgets > Retro Music Widget.\n\n3. Tap the widget to open your music app.");
        Button btn = new Button(this);
        btn.setText("Allow music access");
        btn.setOnClickListener(v -> startActivity(new Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)));
        l.addView(t);
        l.addView(btn);
        setContentView(l);
    }
}
XEOF
cat > app/src/main/java/com/retro/musicwidget/NotifListener.java << 'XEOF'
package com.retro.musicwidget;

import android.content.ComponentName;
import android.content.Context;
import android.media.MediaMetadata;
import android.media.session.MediaController;
import android.media.session.MediaSession;
import android.media.session.MediaSessionManager;
import android.media.session.PlaybackState;
import android.service.notification.NotificationListenerService;
import android.service.notification.StatusBarNotification;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class NotifListener extends NotificationListenerService {
    private final Set<MediaSession.Token> hooked = new HashSet<>();
    private final MediaController.Callback cb = new MediaController.Callback() {
        @Override public void onPlaybackStateChanged(PlaybackState s) { MusicWidget.refresh(NotifListener.this); }
        @Override public void onMetadataChanged(MediaMetadata m) { MusicWidget.refresh(NotifListener.this); }
    };

    @Override
    public void onListenerConnected() {
        MediaSessionManager sm = (MediaSessionManager) getSystemService(Context.MEDIA_SESSION_SERVICE);
        ComponentName cn = new ComponentName(this, NotifListener.class);
        sm.addOnActiveSessionsChangedListener(l -> { hook(l); MusicWidget.refresh(this); }, cn);
        try { hook(sm.getActiveSessions(cn)); } catch (SecurityException e) { }
        MusicWidget.refresh(this);
    }

    private void hook(List<MediaController> l) {
        if (l == null) return;
        for (MediaController c : l) {
            if (hooked.add(c.getSessionToken())) c.registerCallback(cb);
        }
    }

    @Override public void onNotificationPosted(StatusBarNotification s) { MusicWidget.refresh(this); }
    @Override public void onNotificationRemoved(StatusBarNotification s) { MusicWidget.refresh(this); }
}
XEOF
cat > app/src/main/java/com/retro/musicwidget/MusicWidget.java << 'XEOF'
package com.retro.musicwidget;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.media.MediaMetadata;
import android.media.session.MediaController;
import android.media.session.MediaSessionManager;
import android.media.session.PlaybackState;
import android.view.View;
import android.widget.RemoteViews;
import java.util.List;

public class MusicWidget extends AppWidgetProvider {
    static final String A_PLAY = "com.retro.musicwidget.PLAY";
    static final String A_NEXT = "com.retro.musicwidget.NEXT";
    static final String A_PREV = "com.retro.musicwidget.PREV";

    @Override
    public void onUpdate(Context c, AppWidgetManager m, int[] ids) {
        m.updateAppWidget(ids, build(c));
    }

    @Override
    public void onReceive(Context c, Intent i) {
        super.onReceive(c, i);
        String a = i.getAction();
        if (a == null) return;
        MediaController mc = active(c);
        if (mc != null) {
            MediaController.TransportControls t = mc.getTransportControls();
            if (a.equals(A_PLAY)) {
                PlaybackState s = mc.getPlaybackState();
                if (s != null && s.getState() == PlaybackState.STATE_PLAYING) t.pause(); else t.play();
            } else if (a.equals(A_NEXT)) t.skipToNext();
            else if (a.equals(A_PREV)) t.skipToPrevious();
        }
        refresh(c);
    }

    static MediaController active(Context c) {
        try {
            MediaSessionManager sm = (MediaSessionManager) c.getSystemService(Context.MEDIA_SESSION_SERVICE);
            List<MediaController> l = sm.getActiveSessions(new ComponentName(c, NotifListener.class));
            if (l == null || l.isEmpty()) return null;
            for (MediaController x : l) {
                PlaybackState s = x.getPlaybackState();
                if (s != null && s.getState() == PlaybackState.STATE_PLAYING) return x;
            }
            return l.get(0);
        } catch (SecurityException e) {
            return null;
        }
    }

    static void refresh(Context c) {
        AppWidgetManager m = AppWidgetManager.getInstance(c);
        int[] ids = m.getAppWidgetIds(new ComponentName(c, MusicWidget.class));
        if (ids.length > 0) m.updateAppWidget(ids, build(c));
    }

    static RemoteViews build(Context c) {
        RemoteViews v = new RemoteViews(c.getPackageName(), R.layout.widget_music);
        SharedPreferences sp = c.getSharedPreferences("w", 0);
        MediaController mc = active(c);
        boolean playing = false;
        String title = "Nothing playing";
        String artist = "Tap to open music";
        if (mc != null) {
            sp.edit().putString("pkg", mc.getPackageName()).apply();
            MediaMetadata md = mc.getMetadata();
            if (md != null) {
                CharSequence t = md.getText(MediaMetadata.METADATA_KEY_TITLE);
                CharSequence a = md.getText(MediaMetadata.METADATA_KEY_ARTIST);
                if (t != null) {
                    title = t.toString();
                    artist = a != null ? a.toString() : "";
                }
            }
            PlaybackState s = mc.getPlaybackState();
            playing = s != null && s.getState() == PlaybackState.STATE_PLAYING;
        }
        v.setTextViewText(R.id.title, title);
        v.setTextViewText(R.id.artist, artist);
        v.setViewVisibility(R.id.flipper, playing ? View.VISIBLE : View.GONE);
        v.setViewVisibility(R.id.still, playing ? View.GONE : View.VISIBLE);
        v.setImageViewResource(R.id.btn_play, playing ? android.R.drawable.ic_media_pause : android.R.drawable.ic_media_play);

        Intent open = null;
        String pkg = sp.getString("pkg", null);
        if (pkg != null) open = c.getPackageManager().getLaunchIntentForPackage(pkg);
        if (open == null) open = Intent.makeMainSelectorActivity(Intent.ACTION_MAIN, Intent.CATEGORY_APP_MUSIC);
        open.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        PendingIntent po = PendingIntent.getActivity(c, 0, open, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        v.setOnClickPendingIntent(R.id.root, po);
        v.setOnClickPendingIntent(R.id.cassette, po);
        v.setOnClickPendingIntent(R.id.btn_prev, act(c, A_PREV, 1));
        v.setOnClickPendingIntent(R.id.btn_play, act(c, A_PLAY, 2));
        v.setOnClickPendingIntent(R.id.btn_next, act(c, A_NEXT, 3));
        return v;
    }

    static PendingIntent act(Context c, String a, int code) {
        Intent i = new Intent(c, MusicWidget.class).setAction(a);
        return PendingIntent.getBroadcast(c, code, i, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
    }
}
XEOF
cat > app/src/main/res/xml/widget_info.xml << 'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="250dp"
    android:minHeight="70dp"
    android:targetCellWidth="4"
    android:targetCellHeight="1"
    android:updatePeriodMillis="1800000"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen"
    android:initialLayout="@layout/widget_music"/>
XEOF
cat > app/src/main/res/drawable/widget_bg.xml << 'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="#8C1E1510"/>
    <corners android:radius="18dp"/>
    <stroke android:width="1dp" android:color="#66D9A441"/>
</shape>
XEOF
cat > app/src/main/res/drawable/cassette_body.xml << 'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="120dp" android:height="80dp" android:viewportWidth="120" android:viewportHeight="80">
    <path android:fillColor="#D9A441" android:pathData="M8,2H112A6,6 0 0 1 118,8V72A6,6 0 0 1 112,78H8A6,6 0 0 1 2,72V8A6,6 0 0 1 8,2Z"/>
    <path android:fillColor="#F3E6C8" android:pathData="M12,7H108V30H12Z"/>
    <path android:fillColor="#C0392B" android:pathData="M12,23H108V27H12Z"/>
    <path android:fillColor="#2B1D14" android:pathData="M18,34H102V70H18Z"/>
</vector>
XEOF
cat > app/src/main/res/drawable/reel.xml << 'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="28dp" android:height="28dp" android:viewportWidth="24" android:viewportHeight="24">
    <path android:fillColor="#F3E6C8" android:pathData="M12,1A11,11 0 1,0 12,23A11,11 0 1,0 12,1Z"/>
    <path android:strokeColor="#2B1D14" android:strokeWidth="2.4" android:strokeLineCap="round" android:pathData="M12,12L12,3M12,12L19.8,16.5M12,12L4.2,16.5"/>
    <path android:fillColor="#2B1D14" android:pathData="M12,8A4,4 0 1,0 12,16A4,4 0 1,0 12,8Z"/>
</vector>
XEOF
cat > app/src/main/res/layout/widget_music.xml << 'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/root"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="horizontal"
    android:gravity="center_vertical"
    android:padding="8dp"
    android:background="@drawable/widget_bg">
    <FrameLayout
        android:id="@+id/cassette"
        android:layout_width="81dp"
        android:layout_height="54dp">
        <ImageView
            android:id="@+id/still"
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:scaleType="fitCenter"
            android:src="@drawable/cassette_0"/>
        <ViewFlipper
            android:id="@+id/flipper"
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:autoStart="true"
            android:flipInterval="220"
            android:visibility="gone">
            <ImageView android:layout_width="match_parent" android:layout_height="match_parent" android:scaleType="fitCenter" android:src="@drawable/cassette_0"/>
            <ImageView android:layout_width="match_parent" android:layout_height="match_parent" android:scaleType="fitCenter" android:src="@drawable/cassette_1"/>
            <ImageView android:layout_width="match_parent" android:layout_height="match_parent" android:scaleType="fitCenter" android:src="@drawable/cassette_2"/>
            <ImageView android:layout_width="match_parent" android:layout_height="match_parent" android:scaleType="fitCenter" android:src="@drawable/cassette_3"/>
        </ViewFlipper>
    </FrameLayout>
    <LinearLayout
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_weight="1"
        android:layout_marginStart="10dp"
        android:orientation="vertical">
        <TextView
            android:id="@+id/title"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:fontFamily="monospace"
            android:textStyle="bold"
            android:textSize="14sp"
            android:textColor="#F3E6C8"
            android:maxLines="1"
            android:ellipsize="end"/>
        <TextView
            android:id="@+id/artist"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:fontFamily="monospace"
            android:textSize="12sp"
            android:textColor="#D9A441"
            android:maxLines="1"
            android:ellipsize="end"/>
    </LinearLayout>
    <ImageButton android:id="@+id/btn_prev" android:layout_width="36dp" android:layout_height="36dp" android:background="@null" android:src="@android:drawable/ic_media_previous"/>
    <ImageButton android:id="@+id/btn_play" android:layout_width="40dp" android:layout_height="40dp" android:background="@null" android:src="@android:drawable/ic_media_play"/>
    <ImageButton android:id="@+id/btn_next" android:layout_width="36dp" android:layout_height="36dp" android:background="@null" android:src="@android:drawable/ic_media_next"/>
</LinearLayout>
XEOF
for k in 0 1 2 3; do
a=$((k*30))
cat > app/src/main/res/drawable/cassette_$k.xml << XEOF
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@drawable/cassette_body"/>
    <item android:left="28dp" android:top="38dp" android:width="28dp" android:height="28dp">
        <rotate android:drawable="@drawable/reel" android:fromDegrees="$a" android:toDegrees="$a" android:pivotX="50%" android:pivotY="50%"/>
    </item>
    <item android:left="64dp" android:top="38dp" android:width="28dp" android:height="28dp">
        <rotate android:drawable="@drawable/reel" android:fromDegrees="$a" android:toDegrees="$a" android:pivotX="50%" android:pivotY="50%"/>
    </item>
</layer-list>
XEOF
done
