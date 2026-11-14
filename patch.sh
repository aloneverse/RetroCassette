set -e
D=app/src/main/res/drawable
J=app/src/main/java/com/retro/musicwidget
sed -i 's/cassette_body/deck_still/' app/src/main/AndroidManifest.xml
cat > $D/widget_bg.xml << 'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="#8C1E1510"/>
    <corners android:radius="30dp"/>
    <stroke android:width="1dp" android:color="#66D9A441"/>
</shape>
XEOF
cat > $D/progress_retro.xml << 'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:id="@android:id/background">
        <shape><corners android:radius="2dp"/><solid android:color="#44F3E6C8"/></shape>
    </item>
    <item android:id="@android:id/progress">
        <clip><shape><corners android:radius="2dp"/><solid android:color="#D9A441"/></shape></clip>
    </item>
</layer-list>
XEOF
cat > $D/deck.xml << 'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="110dp" android:height="80dp" android:viewportWidth="110" android:viewportHeight="80">
    <path android:fillColor="#5B3A22" android:pathData="M6,0H104A6,6 0 0 1 110,6V74A6,6 0 0 1 104,80H6A6,6 0 0 1 0,74V6A6,6 0 0 1 6,0Z"/>
    <path android:fillColor="#2A2724" android:pathData="M8,3H102A5,5 0 0 1 107,8V72A5,5 0 0 1 102,77H8A5,5 0 0 1 3,72V8A5,5 0 0 1 8,3Z"/>
    <path android:fillColor="#B08D3C" android:pathData="M42,3.5A36.5,36.5 0 1,0 42,76.5A36.5,36.5 0 1,0 42,3.5Z"/>
    <path android:fillColor="#B08D3C" android:pathData="M98,8A8,8 0 1,0 98,24A8,8 0 1,0 98,8Z"/>
    <path android:fillColor="#2A2724" android:pathData="M98,12A4,4 0 1,0 98,20A4,4 0 1,0 98,12Z"/>
</vector>
XEOF
cat > $D/vinyl.xml << 'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="80dp" android:height="80dp" android:viewportWidth="80" android:viewportHeight="80">
    <path android:fillColor="#0D0D0D" android:strokeColor="#2A2A2A" android:strokeWidth="1" android:pathData="M40,6A34,34 0 1,0 40,74A34,34 0 1,0 40,6Z"/>
    <path android:strokeColor="#1FFFFFFF" android:strokeWidth="0.5" android:pathData="M40,12A28,28 0 1,0 40,68A28,28 0 1,0 40,12Z"/>
    <path android:strokeColor="#1FFFFFFF" android:strokeWidth="0.5" android:pathData="M40,18A22,22 0 1,0 40,62A22,22 0 1,0 40,18Z"/>
    <path android:fillColor="#38FFFFFF" android:pathData="M40,40L50.94,9.93A32,32 0 0 1 62.23,16.98Z"/>
    <path android:fillColor="#38FFFFFF" android:pathData="M40,40L29.06,70.07A32,32 0 0 1 17.77,63.02Z"/>
    <path android:fillColor="#2B2118" android:pathData="M40,27A13,13 0 1,0 40,53A13,13 0 1,0 40,27Z"/>
    <path android:strokeColor="#C9A24A" android:strokeWidth="1.2" android:pathData="M40,31A9,9 0 1,0 40,49A9,9 0 1,0 40,31Z"/>
    <path android:strokeColor="#C9A24A" android:strokeWidth="1" android:pathData="M40,34.5A5.5,5.5 0 1,0 40,45.5A5.5,5.5 0 1,0 40,34.5Z"/>
    <path android:fillColor="#C8CCD2" android:pathData="M40,38.4A1.6,1.6 0 1,0 40,41.6A1.6,1.6 0 1,0 40,38.4Z"/>
</vector>
XEOF
cat > $D/arm_on.xml << 'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="110dp" android:height="80dp" android:viewportWidth="110" android:viewportHeight="80">
    <path android:strokeColor="#8A8F98" android:strokeWidth="5" android:strokeLineCap="round" android:pathData="M98,16L106,11.6"/>
    <path android:strokeColor="#C9CED6" android:strokeWidth="2.2" android:strokeLineCap="round" android:pathData="M98,16L68.5,32.4"/>
    <path android:strokeColor="#1A1A1A" android:strokeWidth="4" android:pathData="M68.5,32.4L62,36"/>
    <path android:fillColor="#D9B85B" android:pathData="M98,12.5A3.5,3.5 0 1,0 98,19.5A3.5,3.5 0 1,0 98,12.5Z"/>
</vector>
XEOF
cat > $D/arm_off.xml << 'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="110dp" android:height="80dp" android:viewportWidth="110" android:viewportHeight="80">
    <path android:strokeColor="#8A8F98" android:strokeWidth="5" android:strokeLineCap="round" android:pathData="M98,16L98,8"/>
    <path android:strokeColor="#C9CED6" android:strokeWidth="2.2" android:strokeLineCap="round" android:pathData="M98,16L98,49.8"/>
    <path android:strokeColor="#1A1A1A" android:strokeWidth="4" android:pathData="M98,49.8L98,57.2"/>
    <path android:fillColor="#D9B85B" android:pathData="M98,12.5A3.5,3.5 0 1,0 98,19.5A3.5,3.5 0 1,0 98,12.5Z"/>
</vector>
XEOF
cat > $D/deck_still.xml << 'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@drawable/deck"/>
    <item android:left="2dp" android:width="80dp" android:height="80dp" android:drawable="@drawable/vinyl"/>
    <item android:drawable="@drawable/arm_off"/>
</layer-list>
XEOF
k=0
for a in 0 22.5 45 67.5 90 112.5 135 157.5; do
cat > $D/deck_$k.xml << XEOF
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@drawable/deck"/>
    <item android:left="2dp" android:width="80dp" android:height="80dp">
        <rotate android:drawable="@drawable/vinyl" android:fromDegrees="$a" android:toDegrees="$a" android:pivotX="50%" android:pivotY="50%"/>
    </item>
    <item android:drawable="@drawable/arm_on"/>
</layer-list>
XEOF
k=$((k+1))
done
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
    <FrameLayout android:id="@+id/cassette" android:layout_width="76dp" android:layout_height="55dp">
        <ImageView android:id="@+id/still" android:layout_width="match_parent" android:layout_height="match_parent" android:scaleType="fitCenter" android:src="@drawable/deck_still"/>
        <ViewFlipper android:id="@+id/flipper" android:layout_width="match_parent" android:layout_height="match_parent" android:autoStart="true" android:flipInterval="112" android:visibility="gone">
            <ImageView android:layout_width="match_parent" android:layout_height="match_parent" android:scaleType="fitCenter" android:src="@drawable/deck_0"/>
            <ImageView android:layout_width="match_parent" android:layout_height="match_parent" android:scaleType="fitCenter" android:src="@drawable/deck_1"/>
            <ImageView android:layout_width="match_parent" android:layout_height="match_parent" android:scaleType="fitCenter" android:src="@drawable/deck_2"/>
            <ImageView android:layout_width="match_parent" android:layout_height="match_parent" android:scaleType="fitCenter" android:src="@drawable/deck_3"/>
            <ImageView android:layout_width="match_parent" android:layout_height="match_parent" android:scaleType="fitCenter" android:src="@drawable/deck_4"/>
            <ImageView android:layout_width="match_parent" android:layout_height="match_parent" android:scaleType="fitCenter" android:src="@drawable/deck_5"/>
            <ImageView android:layout_width="match_parent" android:layout_height="match_parent" android:scaleType="fitCenter" android:src="@drawable/deck_6"/>
            <ImageView android:layout_width="match_parent" android:layout_height="match_parent" android:scaleType="fitCenter" android:src="@drawable/deck_7"/>
        </ViewFlipper>
    </FrameLayout>
    <LinearLayout android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:layout_marginStart="8dp" android:orientation="vertical">
        <TextView android:id="@+id/title" android:layout_width="match_parent" android:layout_height="wrap_content" android:fontFamily="monospace" android:textStyle="bold" android:textSize="14sp" android:textColor="#F3E6C8" android:maxLines="1" android:ellipsize="end"/>
        <TextView android:id="@+id/artist" android:layout_width="match_parent" android:layout_height="wrap_content" android:fontFamily="monospace" android:textSize="12sp" android:textColor="#D9A441" android:maxLines="1" android:ellipsize="end"/>
        <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:layout_marginTop="4dp" android:gravity="center_vertical" android:orientation="horizontal">
            <ProgressBar android:id="@+id/progress" style="?android:attr/progressBarStyleHorizontal" android:layout_width="0dp" android:layout_height="4dp" android:layout_weight="1" android:minHeight="4dp" android:maxHeight="4dp" android:max="1000" android:progress="0" android:progressDrawable="@drawable/progress_retro"/>
            <TextView android:id="@+id/time" android:layout_width="wrap_content" android:layout_height="wrap_content" android:layout_marginStart="6dp" android:fontFamily="monospace" android:textSize="10sp" android:textColor="#F3E6C8" android:text="0:00 / 0:00" android:maxLines="1"/>
        </LinearLayout>
    </LinearLayout>
    <ImageButton android:id="@+id/btn_prev" android:layout_width="30dp" android:layout_height="36dp" android:background="@null" android:src="@android:drawable/ic_media_previous"/>
    <ImageButton android:id="@+id/btn_play" android:layout_width="34dp" android:layout_height="40dp" android:background="@null" android:src="@android:drawable/ic_media_play"/>
    <ImageButton android:id="@+id/btn_next" android:layout_width="30dp" android:layout_height="36dp" android:background="@null" android:src="@android:drawable/ic_media_next"/>
</LinearLayout>
XEOF
cat > $J/NotifListener.java << 'XEOF'
package com.retro.musicwidget;

import android.content.ComponentName;
import android.content.Context;
import android.media.MediaMetadata;
import android.media.session.MediaController;
import android.media.session.MediaSession;
import android.media.session.MediaSessionManager;
import android.media.session.PlaybackState;
import android.os.Handler;
import android.os.Looper;
import android.os.PowerManager;
import android.service.notification.NotificationListenerService;
import android.service.notification.StatusBarNotification;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class NotifListener extends NotificationListenerService {
    private final Set<MediaSession.Token> hooked = new HashSet<>();
    private final Handler h = new Handler(Looper.getMainLooper());
    private boolean ticking = false;

    private final Runnable tickR = new Runnable() {
        @Override public void run() {
            MediaController mc = MusicWidget.active(NotifListener.this);
            PlaybackState s = mc != null ? mc.getPlaybackState() : null;
            boolean playing = s != null && s.getState() == PlaybackState.STATE_PLAYING;
            if (!playing) { ticking = false; return; }
            PowerManager pm = (PowerManager) getSystemService(Context.POWER_SERVICE);
            if (pm.isInteractive()) MusicWidget.tick(NotifListener.this);
            h.postDelayed(this, 1000);
        }
    };

    private void startTick() {
        if (!ticking) { ticking = true; h.post(tickR); }
    }

    private final MediaController.Callback cb = new MediaController.Callback() {
        @Override public void onPlaybackStateChanged(PlaybackState s) { MusicWidget.refresh(NotifListener.this); startTick(); }
        @Override public void onMetadataChanged(MediaMetadata m) { MusicWidget.refresh(NotifListener.this); }
    };

    @Override
    public void onListenerConnected() {
        MediaSessionManager sm = (MediaSessionManager) getSystemService(Context.MEDIA_SESSION_SERVICE);
        ComponentName cn = new ComponentName(this, NotifListener.class);
        sm.addOnActiveSessionsChangedListener(l -> { hook(l); MusicWidget.refresh(this); startTick(); }, cn);
        try { hook(sm.getActiveSessions(cn)); } catch (SecurityException e) { }
        MusicWidget.refresh(this);
        startTick();
    }

    private void hook(List<MediaController> l) {
        if (l == null) return;
        for (MediaController c : l) {
            if (hooked.add(c.getSessionToken())) c.registerCallback(cb);
        }
    }

    @Override public void onNotificationPosted(StatusBarNotification s) { MusicWidget.refresh(this); startTick(); }
    @Override public void onNotificationRemoved(StatusBarNotification s) { MusicWidget.refresh(this); }
}
XEOF
cat > $J/MusicWidget.java << 'XEOF'
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
import android.os.SystemClock;
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

    static void tick(Context c) {
        AppWidgetManager m = AppWidgetManager.getInstance(c);
        int[] ids = m.getAppWidgetIds(new ComponentName(c, MusicWidget.class));
        if (ids.length == 0) return;
        RemoteViews v = new RemoteViews(c.getPackageName(), R.layout.widget_music);
        fill(v, active(c));
        m.partiallyUpdateAppWidget(ids, v);
    }

    static String fmt(long ms) {
        if (ms < 0) ms = 0;
        long s = ms / 1000;
        return (s / 60) + ":" + (s % 60 < 10 ? "0" : "") + (s % 60);
    }

    static void fill(RemoteViews v, MediaController mc) {
        long dur = 0, pos = 0;
        if (mc != null) {
            MediaMetadata md = mc.getMetadata();
            if (md != null) dur = md.getLong(MediaMetadata.METADATA_KEY_DURATION);
            PlaybackState s = mc.getPlaybackState();
            if (s != null) {
                pos = s.getPosition();
                if (s.getState() == PlaybackState.STATE_PLAYING) {
                    pos += (long) ((SystemClock.elapsedRealtime() - s.getLastPositionUpdateTime()) * s.getPlaybackSpeed());
                }
            }
            if (dur > 0 && pos > dur) pos = dur;
            if (pos < 0) pos = 0;
        }
        v.setProgressBar(R.id.progress, 1000, dur > 0 ? (int) (pos * 1000 / dur) : 0, false);
        v.setTextViewText(R.id.time, fmt(pos) + " / " + fmt(dur));
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
        fill(v, mc);
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
