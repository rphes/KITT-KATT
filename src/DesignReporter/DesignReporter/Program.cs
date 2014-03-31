using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace DesignReporter
{
    class Program
    {
		static Dictionary<string, string> extensions = new Dictionary<string,string>();
		static string srcPath;
		static DirectoryInfo src;
		static string docsPath;
		static DirectoryInfo docs;
        static FileInfo outputPath = new FileInfo("sourcecode.tex");
		static String start =
@"%!TEX program = xelatex
\documentclass{report}
\input{docs/library/import}
\input{docs/library/style}
\addbibresource{docs/library/bibliography.bib}

\title{EPO-4 B2: Source code}
\author{Julio Ballesteros \and Sjoerd Bosma \and Wessel Bruinsma \and Robin Hes}

\begin{document}";

		static StreamWriter file;
		static long hardwareLines = 0;
		static long softwareLines = 0;

        static void Main(string[] args)
        {
			//Build dictionary
			extensions.Add(".cs", "csharp");
			extensions.Add(".c", "c");
			extensions.Add(".h", "c");
			extensions.Add(".xaml", "xaml");
			extensions.Add(".vhdl", "vhdl");
			extensions.Add(".vhd", "vhdl");
			extensions.Add(".m", "matlab");

			//Get input
            Console.WriteLine("DesignReporter started.");
			Console.WriteLine("Paths are absolute or relative to current directory:");
			Console.WriteLine(Directory.GetCurrentDirectory());

			Console.WriteLine("Enter path to source code directory (defaults to \"/src\")");
			srcPath = Console.ReadLine();
			if (String.IsNullOrWhiteSpace(srcPath))
				src = new DirectoryInfo("src");
			else
				src = new DirectoryInfo(srcPath);

			Console.WriteLine("Enter path to documents directory (defaults to \"/docs\")");
			docsPath = Console.ReadLine();
			if (String.IsNullOrWhiteSpace(docsPath))
				docs = new DirectoryInfo("docs");
			else
				docs = new DirectoryInfo(docsPath);

			//Open file
			file = outputPath.CreateText();
			file.WriteLine(start);
			file.WriteLine("\r\n");

			//Start processing
			processDirectory(src, 0);
			
			//Finish up
            file.WriteLine(@"\end{document}");
            file.Close();
			Console.WriteLine("Done. Press any key to exit.");
            Console.WriteLine("Hardware Code Lines: {0}\r\nSoftware Code Lines: {1}", hardwareLines, softwareLines);
			Console.ReadKey();
        }

		/// <summary>
		/// Recursively process all directories contained in the give root directory
		/// </summary>
		/// <param name="d">The directory to start ing</param>
		/// <param name="l">The current recursivity level</param>
		static void processDirectory(DirectoryInfo d, int l)
		{
			bool containsCode = false;
			string bookmarkLevel = "";
			string bookmarkName = "";
			string labelPrefix = "";

			//Enumerate all code files
			List<FileInfo> files = new List<FileInfo>();
			files.AddRange(d.GetFiles("*", SearchOption.TopDirectoryOnly));
			files.Sort((x, y) => StringComparer.OrdinalIgnoreCase.Compare(x.FullName, y.FullName));
			IEnumerable<FileInfo> fileQuery =
			from fileQ in files
			where !fileQ.FullName.Contains("obj") && !fileQ.FullName.Contains("Visual Micro") && !fileQ.FullName.Contains("robotsim") && !fileQ.FullName.Contains("Properties") && !fileQ.FullName.Contains("App.") && !fileQ.FullName.Contains("quartus") && !fileQ.FullName.Contains("DesignReporter") && !fileQ.FullName.Contains("UBERGRAPH") && extensions.ContainsKey(fileQ.Extension)
			select fileQ;

			if (fileQuery.Count() > 0)
			{
				containsCode = true;
				if (l == 0) //currently in root of project
				{
					bookmarkLevel = "section";
					bookmarkName = d.Name;
					labelPrefix = "appsec";
				}
				else if (l == 1)
				{
					bookmarkLevel = "subsection";
					bookmarkName = d.Parent.Name + " - " + d.Name;
					labelPrefix = "appsubsec";
				}
				else
				{
					bookmarkLevel = "subsection";
					bookmarkName = d.Parent.Parent.Name + " - " + d.Parent.Name + " - " + d.Name;
					labelPrefix = "appsubsubsec";
				}

				//Add new section
				file.WriteLine(String.Format("\\{0}{{{1}}}", bookmarkLevel, bookmarkName.Replace("_", @"\_")));
				file.WriteLine(String.Format("\\label{{{0}:{1}}}", labelPrefix, bookmarkName.ToLower().Replace(" ", String.Empty).Replace("_", "-")));

				foreach (FileInfo fi in fileQuery)
				{
					string ext = fi.Extension;
					string caption = fi.Directory.Name + '/' + fi.Name;
					caption = caption.Replace("_", "-");
					string filename = fi.Name;
					filename = filename.Replace("_", "-");
					string pathescaped = fi.FullName.Replace(outputPath.Directory.FullName + "\\", "").Replace('\\', '/');

					//Add source code to file
					file.WriteLine(String.Format("\\label{{lst:{0}}}\r\n\\includecode[{1}]{{{2}}}{{{3}}}\r\n", caption.ToLower().Replace('/', '-'), extensions[ext], caption, pathescaped));
					
					//Count lines
					if (ext == ".vhdl" || ext == ".vhd")
					{
						long lines = CountLinesInFile(fi.FullName);
						hardwareLines += lines;
						Console.WriteLine("Lines: {0} --> file: {1}", lines, fi.Name);
					}
					else
					{
						long lines = CountLinesInFile(fi.FullName);
						softwareLines += lines;
						Console.WriteLine("Lines: {0} --> file: {1}", lines, fi.Name);
					}
				}
			}

			//Enumerate directories
			DirectoryInfo[] directories = d.GetDirectories();

			foreach (DirectoryInfo directory in directories)
			{
				//Process directories in current directory
				if (containsCode)
					processDirectory(directory, l + 1); //increase recursivity level
				else
					processDirectory(directory, l);
			}
		}

		/// <summary>
		/// Count the number of lines in the file specified.
		/// </summary>
		/// <param name="f">The filename to count lines.</param>
		/// <returns>The number of lines in the file.</returns>
		static long CountLinesInFile(string f)
		{
			long count = 0;
			using (StreamReader r = new StreamReader(f))
			{
				string line;
				while (!r.EndOfStream)
				{
					line = r.ReadLine();
					line = line.Trim();
					if (line != null && line != String.Empty)
						count++;
				}
			}
			return count;
		}
    }
}
