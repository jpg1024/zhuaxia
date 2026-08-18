# ============================================================
# 抓虾 Todo - R8 / ProGuard 规则
# ============================================================

# flutter_local_notifications：R8 混淆会裁剪泛型签名（Signature 属性），
# 导致 Gson TypeToken 反序列化定时通知时抛
# "Missing type parameter"（loadScheduledNotifications 崩溃，zonedSchedule 保存失败）
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keepattributes Signature
-keepattributes InnerClasses,EnclosingMethod
