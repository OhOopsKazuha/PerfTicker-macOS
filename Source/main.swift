// SPDX-License-Identifier: GPL-3.0-only
// Copyright (c) 2026 OhOopsKazuha and contributors
// Unofficial macOS reimplementation of QiuSui1145/PerfTicker; see NOTICE.
import AppKit
import WebKit
import IOKit
import Darwin

final class Probe {
 var prev:[Int:(UInt64,UInt64)]=[:]; var time=ProcessInfo.processInfo.systemUptime
 var rx:UInt64=0,tx:UInt64=0; var diskR:Double=0,diskW:Double=0;var ready=false
 let cores=ProcessInfo.processInfo.processorCount
 func registry(_ cls:String,_ property:String)->[[String:Any]] {
  var iterator:io_iterator_t=0;var result=[[String:Any]]()
  guard IOServiceGetMatchingServices(kIOMainPortDefault,IOServiceMatching(cls),&iterator)==KERN_SUCCESS else{return result}
  defer {IOObjectRelease(iterator)}
  while true {let entry=IOIteratorNext(iterator);if entry==0{break};defer{IOObjectRelease(entry)}
   if let p=IORegistryEntryCreateCFProperty(entry,property as CFString,kCFAllocatorDefault,0)?.takeRetainedValue() as? [String:Any]{result.append(p)}
  };return result
 }
 func sample()->[String:Any] {
  let now=ProcessInfo.processInfo.systemUptime,dt=max(0.001,now-time);time=now
  var load=[Double](repeating:0,count:256);let n=Int(pt_cpu(&load,256));load=Array(load.prefix(n))
  var used=0.0,total=0.0,swap=0.0;pt_memory(&used,&total,&swap)
  var r:UInt64=0,t:UInt64=0;pt_network(&r,&t)
  let down=ready && r>=rx ? Double(r-rx)/dt/1048576:0,up=ready && t>=tx ? Double(t-tx)/dt/1048576:0;rx=r;tx=t
  var dr=0.0,dw=0.0;let disks=registry("IOBlockStorageDriver","Statistics")
  for d in disks {dr+=(d["Bytes (Read)"] as? NSNumber)?.doubleValue ?? 0;dw+=(d["Bytes (Write)"] as? NSNumber)?.doubleValue ?? 0}
  let read=ready ? max(0,dr-diskR)/dt/1048576:0,write=ready ? max(0,dw-diskW)/dt/1048576:0;diskR=dr;diskW=dw
  var buffer=[PTProcess](repeating:PTProcess(),count:8192);let count=Int(pt_processes(&buffer,8192));var processes=[[String:Any]](),next=[Int:(UInt64,UInt64)]()
  for var p in buffer.prefix(count) {
   let pid=Int(p.pid);var cpu=0.0
   if let last=prev[pid],last.1==p.started,p.cpu_ns>=last.0 {cpu=min(100,Double(p.cpu_ns-last.0)/1e9/dt/Double(cores)*100)}
   next[pid]=(p.cpu_ns,p.started)
   let name=withUnsafePointer(to:&p.name){$0.withMemoryRebound(to:CChar.self,capacity:256){String(cString:$0)}}
   processes.append(["pid":pid,"name":name,"cpu":cpu,"mem":Double(p.resident)/1048576,"threads":Int(p.threads),"start":String(p.started)])
  };prev=next;processes.sort{($0["cpu"] as! Double)>($1["cpu"] as! Double)}
  var result:[String:Any]=["time":Date().timeIntervalSince1970*1000,"cpu":load.isEmpty ? 0:load.reduce(0,+)/Double(load.count),"cores":load,"mem":total>0 ? used/total*100:0,"memUsed":used,"memTotal":total,"swap":swap,"rx":down,"tx":up,"diskRead":read,"diskWrite":write,"diskAvailable": !disks.isEmpty,"processes":processes,"uptime":now]
  if let gpu=registry("IOAccelerator","PerformanceStatistics").first {
   if let value=gpu["Device Utilization %"] as? NSNumber{result["gpu"]=value.doubleValue}
   if let value=gpu["In use system memory"] as? NSNumber{result["gpuMem"]=value.doubleValue/1073741824}
  }
  ready=true;return result
 }
}

final class App:NSObject,NSApplicationDelegate,WKScriptMessageHandler,WKNavigationDelegate,WKUIDelegate,NSWindowDelegate {
 var window:NSWindow!;var web:WKWebView!;var status:NSStatusItem!;var timer:DispatchSourceTimer?;let queue=DispatchQueue(label:"PerfTicker.sampler",qos:.utility);let probe=Probe();var interval=1.0;var ready=false;var paused=false;var desktop=false;var normalFrame=NSRect.zero
 let smoke=CommandLine.arguments.contains("--smoke")
 func applicationDidFinishLaunching(_ notification:Notification) {
  let menu=NSMenu();let appItem=NSMenuItem();menu.addItem(appItem);let sub=NSMenu();appItem.submenu=sub
  sub.addItem(withTitle:"显示性能行情终端",action:#selector(show),keyEquivalent:"0").target=self
  sub.addItem(.separator());sub.addItem(withTitle:"退出 PerfTicker",action:#selector(quit),keyEquivalent:"q").target=self
  let edit=NSMenuItem();menu.addItem(edit);let em=NSMenu(title:"编辑");edit.submenu=em
  for (title,sel,key) in [("拷贝",#selector(NSText.copy(_:)),"c"),("粘贴",#selector(NSText.paste(_:)),"v"),("全选",#selector(NSText.selectAll(_:)),"a")] {em.addItem(withTitle:title,action:sel,keyEquivalent:key)}
  NSApp.mainMenu=menu
  let conf=WKWebViewConfiguration();if smoke {conf.websiteDataStore = .nonPersistent()};conf.userContentController.add(self,name:"native")
  web=WKWebView(frame:.zero,configuration:conf);web.navigationDelegate=self;web.uiDelegate=self;web.setValue(false,forKey:"drawsBackground")
  window=NSWindow(contentRect:NSRect(x:0,y:0,width:1380,height:900),styleMask:[.titled,.closable,.miniaturizable,.resizable],backing:.buffered,defer:false)
  window.title="性能行情终端 · PerfTicker for Mac";window.minSize=NSSize(width:1040,height:700);window.contentView=web;window.delegate=self
  window.setFrameAutosaveName("PerfTickerMain");window.center();window.makeKeyAndOrderFront(nil)
  status=NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength);status.button?.title="▥ PT"
  let tray=NSMenu();tray.addItem(withTitle:"打开主窗口",action:#selector(show),keyEquivalent:"").target=self
  tray.addItem(withTitle:"退出桌面模式",action:#selector(exitDesktop),keyEquivalent:"").target=self
  tray.addItem(.separator());tray.addItem(withTitle:"退出",action:#selector(quit),keyEquivalent:"").target=self;status.menu=tray
  if let url=Bundle.main.url(forResource:"index",withExtension:"html"){web.loadFileURL(url,allowingReadAccessTo:url.deletingLastPathComponent())}
  NSApp.activate(ignoringOtherApps:true)
 }
 func webView(_ webView:WKWebView,didFinish navigation:WKNavigation!) {
  ready=true;queue.async { _ = self.probe.sample();DispatchQueue.main.async {self.startTimer()} }
  if smoke {
   DispatchQueue.main.asyncAfter(deadline:.now()+4){self.web.evaluateJavaScript("window.runChecks()") {value,error in print("CHECKS",value ?? "nil",error?.localizedDescription ?? "ok")}}
   DispatchQueue.main.asyncAfter(deadline:.now()+30){self.snapshot()}
  }
 }
 func startTimer(){timer?.cancel();let t=DispatchSource.makeTimerSource(queue:queue);t.schedule(deadline:.now()+interval,repeating:interval);t.setEventHandler{[weak self] in guard let self=self else{return};let s=self.probe.sample();guard let data=try? JSONSerialization.data(withJSONObject:s),let json=String(data:data,encoding:.utf8) else{return};DispatchQueue.main.async {if self.ready{self.status.button?.toolTip=String(format:"CPU %.1f%% · GPU %.1f%% · 内存 %.1f%%",s["cpu"] as? Double ?? 0,s["gpu"] as? Double ?? 0,s["mem"] as? Double ?? 0);self.web.evaluateJavaScript("window.receive(\(json))"){_,error in if let error=error{fputs("JS: \(error)\n",stderr)}}}}};timer=t;t.resume()}
 func snapshot(){web.evaluateJavaScript("document.querySelectorAll('dialog[open]').forEach(d=>d.close());document.getElementById('context').style.display='none';renderAll()") {_,_ in DispatchQueue.main.asyncAfter(deadline:.now()+0.3){self.captureSnapshot()}}}
 func captureSnapshot(){let cfg=WKSnapshotConfiguration();cfg.snapshotWidth=1380;web.takeSnapshot(with:cfg){image,error in
   if let image=image,let data=image.tiffRepresentation,let rep=NSBitmapImageRep(data:data),let png=rep.representation(using:.png,properties:[:]){try? png.write(to:URL(fileURLWithPath:ProcessInfo.processInfo.environment["PT_SCREENSHOT"] ?? "/tmp/perfticker-preview.png"))}
   self.web.evaluateJavaScript("JSON.stringify(window.diagnostics())"){value,error in print(value ?? "no diagnostics");NSApp.terminate(nil)}
  }}
 func userContentController(_ userContentController:WKUserContentController,didReceive message:WKScriptMessage){guard let b=message.body as? [String:Any],let action=b["action"] as? String else{return}
  switch action {
   case "interval":interval=max(0.5,min(10,b["value"] as? Double ?? 1));if ready{startTimer()}
   case "top":window.level=(b["value"] as? Bool ?? false) ? .floating:.normal
   case "hide":window.orderOut(nil)
   case "copy":NSPasteboard.general.clearContents();NSPasteboard.general.setString(b["value"] as? String ?? "",forType:.string)
   case "desktop":desktop.toggle();if desktop {normalFrame=window.frame;window.styleMask=[.borderless];window.level=NSWindow.Level(rawValue:Int(CGWindowLevelForKey(.desktopWindow))+1);window.ignoresMouseEvents=true;window.setFrame(NSScreen.main!.frame,display:true)}else{exitDesktop()}
   case "kill":terminateProcess(b)
   default:break
  }
 }
 func webView(_ webView:WKWebView,runJavaScriptConfirmPanelWithMessage message:String,initiatedByFrame frame:WKFrameInfo,completionHandler:@escaping(Bool)->Void){let a=NSAlert();a.messageText=message;a.addButton(withTitle:"继续");a.addButton(withTitle:"取消");a.beginSheetModal(for:window){completionHandler($0 == .alertFirstButtonReturn)}}
 func terminateProcess(_ b:[String:Any]) {
  guard let pid=b["pid"] as? Int,pid>1,pid != Int(getpid()),let start=b["start"] as? String else{return}
  let alert=NSAlert();alert.messageText="结束进程 \(b["name"] as? String ?? "")（\(pid)）？";alert.informativeText="未保存的工作可能丢失。将发送正常终止请求（SIGTERM）。";alert.addButton(withTitle:"取消");alert.addButton(withTitle:"结束进程")
  alert.beginSheetModal(for:window){response in if response == .alertSecondButtonReturn {
   var buffer=[PTProcess](repeating:PTProcess(),count:8192);let n=Int(pt_processes(&buffer,8192))
   let matching=buffer.prefix(n).contains{Int($0.pid)==pid && String($0.started)==start}
   let success=matching && Darwin.kill(Int32(pid),SIGTERM)==0
   self.web.evaluateJavaScript("nativeNotice('\(success ? "已发送终止请求" : "终止失败：权限不足或进程已变更")')",completionHandler:nil)
  }}
 }
 @objc func exitDesktop(){desktop=false;window.ignoresMouseEvents=false;window.level = .normal;window.styleMask=[.titled,.closable,.miniaturizable,.resizable];window.setFrame(normalFrame.isEmpty ? NSRect(x:100,y:100,width:1380,height:900):normalFrame,display:true);show()}
 @objc func show(){if desktop{exitDesktop();return};window.makeKeyAndOrderFront(nil);NSApp.activate(ignoringOtherApps:true)}
 @objc func quit(){NSApp.terminate(nil)}
 func windowShouldClose(_ sender:NSWindow)->Bool{sender.orderOut(nil);return false}
 func applicationShouldHandleReopen(_ sender:NSApplication,hasVisibleWindows flag:Bool)->Bool{show();return true}
 func applicationWillTerminate(_ notification:Notification){timer?.cancel()}
}
if CommandLine.arguments.contains("--self-test") {
 let p=Probe();_ = p.sample();Thread.sleep(forTimeInterval:1);let s=p.sample();let data=try! JSONSerialization.data(withJSONObject:s,options:[.prettyPrinted,.sortedKeys]);print(String(data:data,encoding:.utf8)!)
}else{if !CommandLine.arguments.contains("--smoke"),let id=Bundle.main.bundleIdentifier,let running=NSRunningApplication.runningApplications(withBundleIdentifier:id).first(where:{$0.processIdentifier != getpid()}) {running.activate(options:[]);exit(0)}
let app=NSApplication.shared;app.setActivationPolicy(.regular);let delegate=App();app.delegate=delegate;app.run()}
