// ============================================================
// 抓虾 Todo 单文件自解压启动器（stub）
// 功能：解压内嵌 package.zip 到 %TEMP%\zhuaxia_app，运行 zhuaxia.exe，
//       进程退出后自动清理临时目录。双击即用，无需安装。
// 兼容：Windows 7 SP1 ~ Windows 11（需 .NET Framework 4.5+）
// 编译：csc /nologo /optimize+ /target:winexe /win32icon:xxx.ico
//       /resource:package.zip,package.zip
//       /r:System.IO.Compression.dll /r:System.IO.Compression.FileSystem.dll
// ============================================================
using System;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Reflection;
using System.Threading;

internal static class SingleFileStub
{
    [STAThread]
    private static int Main()
    {
        string extractDir = Path.Combine(Path.GetTempPath(), "zhuaxia_app");
        try
        {
            Assembly asm = Assembly.GetExecutingAssembly();

            // 互斥锁：防止多个实例同时解压冲突
            using (Mutex mutex = new Mutex(false, "Global\\zhuaxia_single_extract"))
            {
                if (!mutex.WaitOne(TimeSpan.FromSeconds(30)))
                    return 1;
                try
                {
                    using (Stream stream = asm.GetManifestResourceStream("package.zip"))
                    {
                        if (stream == null)
                            return 1;
                        using (ZipArchive zip = new ZipArchive(stream, ZipArchiveMode.Read))
                        {
                            foreach (ZipArchiveEntry entry in zip.Entries)
                            {
                                string dest = Path.Combine(extractDir, entry.FullName);
                                if (entry.FullName.EndsWith("/") || entry.FullName.EndsWith("\\"))
                                {
                                    Directory.CreateDirectory(dest);
                                    continue;
                                }
                                string dir = Path.GetDirectoryName(dest);
                                if (!string.IsNullOrEmpty(dir))
                                    Directory.CreateDirectory(dir);
                                entry.ExtractToFile(dest, true);
                            }
                        }
                    }
                }
                finally
                {
                    mutex.ReleaseMutex();
                }
            }

            // 启动主程序（工作目录必须是解压目录，Flutter 依赖相对路径 data/）
            string exePath = Path.Combine(extractDir, "zhuaxia.exe");
            ProcessStartInfo psi = new ProcessStartInfo();
            psi.FileName = exePath;
            psi.WorkingDirectory = extractDir;
            using (Process proc = Process.Start(psi))
            {
                proc.WaitForExit();
            }

            // 清理临时目录（失败静默，系统也会自动清 %TEMP%）
            try { Directory.Delete(extractDir, true); } catch { }
            return 0;
        }
        catch (Exception ex)
        {
            try
            {
                File.WriteAllText(
                    Path.Combine(Path.GetTempPath(), "zhuaxia_single_error.log"),
                    ex.ToString());
            }
            catch { }
            return 1;
        }
    }
}
