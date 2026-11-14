set -e
J=app/src/main/java/com/retro/musicwidget
M=app/src/main/AndroidManifest.xml
sed -i 's#</queries>#<intent><action android:name="android.intent.action.MEDIA_BUTTON"/></intent></queries>#' $M
sed -i 's#</application>#<activity android:name=".LaunchActivity" android:exported="false" android:theme="@android:style/Theme.Translucent.NoTitleBar" android:excludeFromRecents="true" android:noHistory="true"/></application>#' $M
python3 - << 'PYEOF'
p = 'app/src/main/java/com/retro/musicwidget/MusicWidget.java'
s = open(p).read()
a = "            if (l == null || l.isEmpty()) return null;\n"
b = a + """            String mp = c.getSharedPreferences("w", 0).getString("music_pkg", null);
            if (mp != null) {
                List<MediaController> f = new java.util.ArrayList<>();
                for (MediaController q : l) if (mp.equals(q.getPackageName())) f.add(q);
                l = f;
                if (l.isEmpty()) return null;
            }
"""
assert s.count(a) == 1
s = s.replace(a, b)
a2 = """        Intent open = null;
        String pkg = sp.getString("pkg", null);
        if (pkg != null) open = c.getPackageManager().getLaunchIntentForPackage(pkg);
        if (open == null) open = Intent.makeMainSelectorActivity(Intent.ACTION_MAIN, Intent.CATEGORY_APP_MUSIC);
        open.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
"""
assert s.count(a2) == 1
s = s.replace(a2, "        Intent open = new Intent(c, LaunchActivity.class).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);\n")
open(p, 'w').write(s)
PYEOF
cat > $J/LaunchActivity.java << 'XEOF'
package com.retro.musicwidget;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.ResolveInfo;
import android.media.session.MediaController;
import android.media.session.PlaybackState;
import android.os.Bundle;
import android.view.KeyEvent;
import java.util.List;

public class LaunchActivity extends Activity {
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        String pkg = getSharedPreferences("w", 0).getString("music_pkg", null);
        if (pkg == null) {
            startActivity(new Intent(this, MainActivity.class));
            finish();
            return;
        }
        MediaController mc = MusicWidget.active(this);
        if (mc != null) {
            PlaybackState s = mc.getPlaybackState();
            if (s == null || s.getState() != PlaybackState.STATE_PLAYING) mc.getTransportControls().play();
        } else {
            resume(pkg);
        }
        Intent li = getPackageManager().getLaunchIntentForPackage(pkg);
        if (li != null) {
            li.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(li);
        }
        finish();
    }

    private void resume(String pkg) {
        try {
            Intent q = new Intent(Intent.ACTION_MEDIA_BUTTON).setPackage(pkg);
            List<ResolveInfo> rs = getPackageManager().queryBroadcastReceivers(q, 0);
            if (rs.isEmpty()) return;
            ComponentName cn = new ComponentName(pkg, rs.get(0).activityInfo.name);
            for (int act : new int[]{KeyEvent.ACTION_DOWN, KeyEvent.ACTION_UP}) {
                Intent i = new Intent(Intent.ACTION_MEDIA_BUTTON).setComponent(cn);
                i.putExtra(Intent.EXTRA_KEY_EVENT, new KeyEvent(act, KeyEvent.KEYCODE_MEDIA_PLAY));
                sendBroadcast(i);
            }
        } catch (Exception e) { }
    }
}
XEOF
cat > $J/MainActivity.java << 'XEOF'
package com.retro.musicwidget;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.Typeface;
import android.os.Bundle;
import android.provider.Settings;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class MainActivity extends Activity {
    private TextView sel;

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
        t.setText("RETRO MUSIC WIDGET\n\n1. Allow music access.\n\n2. Choose your music app.\n\n3. Long-press home screen > Widgets > add it.\n");
        Button b1 = new Button(this);
        b1.setText("Allow music access");
        b1.setOnClickListener(v -> startActivity(new Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)));
        Button b2 = new Button(this);
        b2.setText("Choose music app");
        b2.setOnClickListener(v -> pick());
        sel = new TextView(this);
        sel.setTextColor(0xFFD9A441);
        sel.setTextSize(15);
        sel.setTypeface(Typeface.MONOSPACE);
        sel.setPadding(0, 32, 0, 0);
        l.addView(t);
        l.addView(b1);
        l.addView(b2);
        l.addView(sel);
        setContentView(l);
        show();
    }

    private void show() {
        String p = getSharedPreferences("w", 0).getString("music_pkg", null);
        String name = "not chosen";
        if (p != null) {
            try {
                PackageManager pm = getPackageManager();
                name = pm.getApplicationLabel(pm.getApplicationInfo(p, 0)).toString();
            } catch (Exception e) {
                name = p;
            }
        }
        sel.setText("Music app: " + name);
    }

    private void pick() {
        final PackageManager pm = getPackageManager();
        Intent main = new Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER);
        List<ResolveInfo> all = pm.queryIntentActivities(main, 0);
        final Set<String> music = new HashSet<>();
        for (ResolveInfo r : pm.queryIntentActivities(Intent.makeMainSelectorActivity(Intent.ACTION_MAIN, Intent.CATEGORY_APP_MUSIC), 0)) {
            music.add(r.activityInfo.packageName);
        }
        Collections.sort(all, (x, y) -> {
            boolean mx = music.contains(x.activityInfo.packageName);
            boolean my = music.contains(y.activityInfo.packageName);
            if (mx != my) return mx ? -1 : 1;
            return x.loadLabel(pm).toString().compareToIgnoreCase(y.loadLabel(pm).toString());
        });
        final List<String> pk = new ArrayList<>();
        List<String> nm = new ArrayList<>();
        for (ResolveInfo r : all) {
            String p = r.activityInfo.packageName;
            pk.add(p);
            nm.add((music.contains(p) ? "* " : "") + r.loadLabel(pm));
        }
        new AlertDialog.Builder(this)
            .setTitle("Choose music app")
            .setItems(nm.toArray(new String[0]), (d, i) -> {
                getSharedPreferences("w", 0).edit().putString("music_pkg", pk.get(i)).apply();
                show();
                MusicWidget.refresh(this);
            })
            .show();
    }
}
XEOF
