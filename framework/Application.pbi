; ============================================================================
; PureBasic OOP GUI Framework - Application.pbi
; Application Manager & Central Event Dispatcher
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "Window.pbi"
XIncludeFile "Gadget.pbi"

Global NewMap UI_GadgetMap.i()
Global NewMap UI_WindowMap.i()

Macro UI_RegisterGadget(id_p, g_p)
  If (id_p >= 0 And g_p)
    UI_GadgetMap(Str(id_p)) = g_p
  EndIf
EndMacro

Macro UI_UnregisterGadget(id_p)
  If (FindMapElement(UI_GadgetMap(), Str(id_p)))
    DeleteMapElement(UI_GadgetMap(), Str(id_p))
  EndIf
EndMacro

Declare UI_GlobalSizeCallback()
Declare.b UI_MVVM_DispatchUIEvent(*control.UI_Gadget_vt, eventType.i)

Procedure UI_GlobalSizeCallback()
  Protected evWin.i = EventWindow()
  If (FindMapElement(UI_WindowMap(), Str(evWin)))
    Protected *w.UI_Window_vt = UI_WindowMap()
    If (*w)
      *w\OnResize(WindowWidth(evWin), WindowHeight(evWin))
    EndIf
  EndIf
EndProcedure

Macro UI_RegisterWindow(id_p, w_p)
  If (id_p >= 0 And w_p)
    UI_WindowMap(Str(id_p)) = w_p
    SmartWindowRefresh(id_p, #True)
    BindEvent(#PB_Event_SizeWindow, @UI_GlobalSizeCallback(), id_p)
  EndIf
EndMacro

Macro UI_UnregisterWindow(id_p)
  If (FindMapElement(UI_WindowMap(), Str(id_p)))
    UnbindEvent(#PB_Event_SizeWindow, @UI_GlobalSizeCallback(), id_p)
    DeleteMapElement(UI_WindowMap(), Str(id_p))
  EndIf
EndMacro

Namespace UI {

  Class Application {
    Protected isRunning.b
    Protected *mainWindow.UI::Window

    Public Method Init() {
      This\isRunning = #False
      This\*mainWindow = #Null
    }

    Public Method Init(appName_p.s) {
      This\isRunning = #False
      This\*mainWindow = #Null
    }

    Public Method SetMainWindow(*win_p.UI::Window) {
      This\*mainWindow = *win_p
    }

    Public Method.i GetMainWindow() {
      ProcedureReturn This\*mainWindow
    }

    Public Method Run() {
      If (MapSize(UI_WindowMap()) = 0)
        ProcedureReturn
      EndIf
      This\isRunning = #True
      Protected ev.i, evGadget.i, evWin.i, evType.i

      While (This\isRunning And MapSize(UI_WindowMap()) > 0) {
        ev = WaitWindowEvent()
        evWin = EventWindow()
        evType = EventType()

        Select (ev) {
          Case #PB_Event_Gadget:
            evGadget = EventGadget()
            If (FindMapElement(UI_GadgetMap(), Str(evGadget))) {
              Protected *g.UI::Gadget = UI_GadgetMap()
              If (*g) {
                ; Dispatch to MVVM Binding Engine
                UI_MVVM_DispatchUIEvent(*g, evType)

                ; Dispatch to Gadget virtual methods
                Select (evType) {
                  Case #PB_EventType_LeftClick:
                    *g\OnClick()
                  Case #PB_EventType_Change:
                    *g\OnChange()
                  Case #PB_EventType_Focus:
                    *g\OnFocus()
                  Case #PB_EventType_LostFocus:
                    *g\OnLostFocus()
                  Case #PB_EventType_RightClick:
                    *g\OnRightClick()
                  Default:
                    *g\OnCustomEvent(evType)
                }

                ; Notify parent window
                If (FindMapElement(UI_WindowMap(), Str(evWin))) {
                  Protected *wNotify.UI::Window = UI_WindowMap()
                  If (*wNotify) {
                    *wNotify\OnChildEvent(*g, evType)
                  }
                }
              }
            }

          Case #PB_Event_CloseWindow:
            Protected isMainWin.b = #False
            If (FindMapElement(UI_WindowMap(), Str(evWin))) {
              Protected *w.UI::Window = UI_WindowMap()
              If (*w) {
                If (This\*mainWindow And *w = This\*mainWindow)
                  isMainWin = #True
                EndIf
                If (*w\OnClose()) {
                  *w\Close()
                  If (isMainWin Or MapSize(UI_WindowMap()) = 0) {
                    This\Quit()
                  }
                }
              }
            } Else {
              CloseWindow(evWin)
              If (MapSize(UI_WindowMap()) = 0) {
                This\Quit()
              }
            }

          Case #PB_Event_SizeWindow:
            If (FindMapElement(UI_WindowMap(), Str(evWin))) {
              Protected *wSize.UI::Window = UI_WindowMap()
              If (*wSize) {
                *wSize\OnResize(WindowWidth(evWin), WindowHeight(evWin))
              }
            }

          Case #PB_Event_MoveWindow:
            If (FindMapElement(UI_WindowMap(), Str(evWin))) {
              Protected *wMove.UI::Window = UI_WindowMap()
              If (*wMove) {
                *wMove\OnMove(WindowX(evWin), WindowY(evWin))
              }
            }

          Case #PB_Event_MinimizeWindow:
            If (FindMapElement(UI_WindowMap(), Str(evWin))) {
              Protected *targetWinMin.UI::Window = UI_WindowMap()
              If (*targetWinMin) {
                *targetWinMin\OnMinimize()
              }
            }

          Case #PB_Event_MaximizeWindow:
            If (FindMapElement(UI_WindowMap(), Str(evWin))) {
              Protected *targetWinMax.UI::Window = UI_WindowMap()
              If (*targetWinMax) {
                *targetWinMax\OnMaximize()
              }
            }

          Case #PB_Event_RestoreWindow:
            If (FindMapElement(UI_WindowMap(), Str(evWin))) {
              Protected *targetWinRest.UI::Window = UI_WindowMap()
              If (*targetWinRest) {
                *targetWinRest\OnRestore()
              }
            }

          Case #PB_Event_Timer:
            If (FindMapElement(UI_WindowMap(), Str(evWin))) {
              Protected *targetWinTimer.UI::Window = UI_WindowMap()
              If (*targetWinTimer) {
                *targetWinTimer\OnTimer(EventTimer())
              }
            }
        }
      }
    }

    Public Method Run(*mainWin_p.UI::Window) {
      If (*mainWin_p) {
        This\*mainWindow = *mainWin_p
      }
      This\Run()
    }

    Public Method Quit() {
      This\isRunning = #False
    }

    Public Method Free() {
      This\Quit()
    }
  }

}
