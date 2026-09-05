; ============================================================================
; PureBasic OOP GUI Framework - Window.pbi
; Standard GUI Window Wrapper with Multi-Constructors & Dynamic Accessors
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "Component.pbi"
XIncludeFile "Gadget.pbi"

Namespace UI {

  Class Window Extends Component {
    Protected title.s
    Protected flags.i
    Protected parentID.i
    Protected Map *namedControls.UI::Component()

    ; ------------------------------------------------------------------------
    ; Internal Window Creation Helper
    ; ------------------------------------------------------------------------
    Protected Method CreateWindowInternal(title_p.s, x_p.i, y_p.i, w_p.i, h_p.i, flags_p.i, parent_p.i) {
      This\title = title_p
      This\flags = flags_p
      This\parentID = parent_p

      Protected pHandle.i = 0
      If (parent_p <> 0) {
        If (IsWindow(parent_p)) {
          pHandle = WindowID(parent_p)
        } Else {
          pHandle = parent_p
        }
      }

      If (pHandle <> 0) {
        This\id = OpenWindow(#PB_Any, x_p, y_p, w_p, h_p, title_p, flags_p, pHandle)
      } Else {
        This\id = OpenWindow(#PB_Any, x_p, y_p, w_p, h_p, title_p, flags_p)
      }

      If (This\id) {
        UI_RegisterWindow(This\id, This)
        This\x = WindowX(This\id)
        This\y = WindowY(This\id)
        This\width = WindowWidth(This\id)
        This\height = WindowHeight(This\id)
        This\isVisible = #True
        This\isEnabled = #True
      }
    }

    ; ------------------------------------------------------------------------
    ; 1. Multiple Overloaded Constructors
    ; ------------------------------------------------------------------------

    ; Constructeur 0: Vierge (pret pour LoadView)
    Public Method Init() {
      Super\Init()
      This\id = 0
      This\title = "Window"
      This\width = 800
      This\height = 600
    }

    ; Constructeur 1: Titre uniquement (800x600, Centree a l'ecran, Menu Systeme + Reduire + Agrandir + Redimensionnable)
    Public Method Init(title_p.s) {
      Protected defFlags.i = #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget
      This\CreateWindowInternal(title_p, #PB_Ignore, #PB_Ignore, 800, 600, defFlags, 0)
    }

    ; Constructeur 2: Titre, Largeur, Hauteur (Centree a l'ecran, Redimensionnable)
    Public Method Init(title_p.s, w_p.i, h_p.i) {
      Protected defFlags.i = #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget
      This\CreateWindowInternal(title_p, #PB_Ignore, #PB_Ignore, w_p, h_p, defFlags, 0)
    }

    ; Constructeur 3: Titre, Largeur, Hauteur, Flags
    Public Method Init(title_p.s, w_p.i, h_p.i, flags_p.i) {
      This\CreateWindowInternal(title_p, #PB_Ignore, #PB_Ignore, w_p, h_p, flags_p, 0)
    }

    ; Constructeur 4: Titre, X, Y, Largeur, Hauteur
    Public Method Init(title_p.s, x_p.i, y_p.i, w_p.i, h_p.i) {
      Protected defFlags.i = #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget
      This\CreateWindowInternal(title_p, x_p, y_p, w_p, h_p, defFlags, 0)
    }

    ; Constructeur 5: Titre, X, Y, Largeur, Hauteur, Flags
    Public Method Init(title_p.s, x_p.i, y_p.i, w_p.i, h_p.i, flags_p.i) {
      This\CreateWindowInternal(title_p, x_p, y_p, w_p, h_p, flags_p, 0)
    }

    ; Constructeur 6: Complet (Titre, X, Y, Largeur, Hauteur, Flags, ParentID)
    Public Method Init(title_p.s, x_p.i, y_p.i, w_p.i, h_p.i, flags_p.i, parent_p.i) {
      This\CreateWindowInternal(title_p, x_p, y_p, w_p, h_p, flags_p, parent_p)
    }

    ; ------------------------------------------------------------------------
    ; 2. Getters & Setters Synchronisés
    ; ------------------------------------------------------------------------

    Public Method SetTitle(t.s) {
      This\title = t
      If (This\id And IsWindow(This\id)) {
        SetWindowTitle(This\id, t)
      }
    }

    Public Method.s GetTitle() {
      If (This\id And IsWindow(This\id)) {
        ProcedureReturn GetWindowTitle(This\id)
      }
      ProcedureReturn This\title
    }

    Public Method SetX(nx.i) {
      This\x = nx
      If (This\id And IsWindow(This\id)) {
        ResizeWindow(This\id, nx, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      }
    }

    Public Method.i GetX() {
      If (This\id And IsWindow(This\id)) {
        ProcedureReturn WindowX(This\id)
      }
      ProcedureReturn This\x
    }

    Public Method SetY(ny.i) {
      This\y = ny
      If (This\id And IsWindow(This\id)) {
        ResizeWindow(This\id, #PB_Ignore, ny, #PB_Ignore, #PB_Ignore)
      }
    }

    Public Method.i GetY() {
      If (This\id And IsWindow(This\id)) {
        ProcedureReturn WindowY(This\id)
      }
      ProcedureReturn This\y
    }

    Public Method SetWidth(nw.i) {
      This\width = nw
      If (This\id And IsWindow(This\id)) {
        ResizeWindow(This\id, #PB_Ignore, #PB_Ignore, nw, #PB_Ignore)
      }
    }

    Public Method.i GetWidth() {
      If (This\id And IsWindow(This\id)) {
        ProcedureReturn WindowWidth(This\id)
      }
      ProcedureReturn This\width
    }

    Public Method SetHeight(nh.i) {
      This\height = nh
      If (This\id And IsWindow(This\id)) {
        ResizeWindow(This\id, #PB_Ignore, #PB_Ignore, #PB_Ignore, nh)
      }
    }

    Public Method.i GetHeight() {
      If (This\id And IsWindow(This\id)) {
        ProcedureReturn WindowHeight(This\id)
      }
      ProcedureReturn This\height
    }

    Public Method SetLocation(nx.i, ny.i) {
      This\x = nx : This\y = ny
      If (This\id And IsWindow(This\id)) {
        ResizeWindow(This\id, nx, ny, #PB_Ignore, #PB_Ignore)
      }
    }

    Public Method SetSize(nw.i, nh.i) {
      This\width = nw : This\height = nh
      If (This\id And IsWindow(This\id)) {
        ResizeWindow(This\id, #PB_Ignore, #PB_Ignore, nw, nh)
      }
    }

    Public Method SetPosition(nx.i, ny.i, nw.i, nh.i) {
      This\x = nx : This\y = ny : This\width = nw : This\height = nh
      If (This\id And IsWindow(This\id)) {
        ResizeWindow(This\id, nx, ny, nw, nh)
      }
    }

    Public Method.i GetFlags() {
      ProcedureReturn This\flags
    }

    Public Method SetFlags(f.i) {
      This\flags = f
    }

    Public Method.i GetParentID() {
      ProcedureReturn This\parentID
    }

    Public Method SetParentID(p.i) {
      This\parentID = p
    }

    Public Method SetVisible(v.b) {
      This\isVisible = v
      If (This\id And IsWindow(This\id)) {
        HideWindow(This\id, 1 - v)
      }
    }

    Public Method SetEnabled(e.b) {
      This\isEnabled = e
      If (This\id And IsWindow(This\id)) {
        DisableWindow(This\id, 1 - e)
      }
    }

    Protected *rootContent.UI::Component

    Public Method SetContent(*content.UI::Component) {
      This\rootContent = *content
      If (*content And This\id And IsWindow(This\id)) {
        *content\Arrange(0, 0, WindowWidth(This\id), WindowHeight(This\id))
      }
    }

    Public Method.i GetContent() {
      ProcedureReturn This\rootContent
    }

    Public Method RegisterControl(name_p.s, *ctrl.UI::Component) {
      If (name_p <> "" And *ctrl) {
        This\namedControls(LCase(name_p)) = *ctrl
      }
    }

    Public Method.i FindControl(name_p.s) {
      If (FindMapElement(This\namedControls(), LCase(name_p))) {
        ProcedureReturn This\namedControls()
      }
      ProcedureReturn 0
    }

    Public Method SetDataContext(*dc) {
      This\dataContext = *dc
    }

    Public Method.i GetDataContext() {
      ProcedureReturn This\dataContext
    }

    Public Method.b LoadView(xmlPath.s, *dataContext_p = 0) {
      If (*dataContext_p) {
        This\SetDataContext(*dataContext_p)
      }
      Protected *loader.UI::XMLLoader = New UI::XMLLoader()
      Protected res.b = #False
      If (*loader) {
        res = *loader\LoadFromFile(xmlPath, This)
        *loader\Free()
      }
      ProcedureReturn res
    }

    Public Method.b LoadViewFromString(xmlContent.s, *dataContext_p = 0) {
      If (*dataContext_p) {
        This\SetDataContext(*dataContext_p)
      }
      Protected *loader.UI::XMLLoader = New UI::XMLLoader()
      Protected res.b = #False
      If (*loader) {
        res = *loader\LoadFromString(xmlContent, This)
        *loader\Free()
      }
      ProcedureReturn res
    }

    ; ------------------------------------------------------------------------
    ; 3. Window Lifecycle & Event Handlers
    ; ------------------------------------------------------------------------

    Public Method Close() {
      If (This\id And IsWindow(This\id)) {
        UI_UnregisterWindow(This\id)
        CloseWindow(This\id)
        This\id = 0
      }
    }

    Public Method Free() {
      This\Close()
    }

    Public Method.b OnClose() {
      ProcedureReturn #True
    }

    Public Method OnResize(newW.i, newH.i) {
      This\width = newW
      This\height = newH
      If (This\rootContent) {
        This\rootContent\Arrange(0, 0, newW, newH)
      }
    }

    Public Method OnMove(newX.i, newY.i) {
      This\x = newX
      This\y = newY
    }

    Public Method OnMinimize() {
    }

    Public Method OnMaximize() {
    }

    Public Method OnRestore() {
    }

    Public Method OnTimer(timerId.i) {
    }

    Public Method OnChildEvent(*child.UI::Gadget, eventType.i) {
    }
  }

}
