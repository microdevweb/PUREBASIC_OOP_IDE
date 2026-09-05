; ============================================================================
; PureBasic OOP MVVM - SimpleView.pbi
; Minimal Code-Behind View with Inline XML Layout
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../SimpleConstants.pbi"
XIncludeFile "../viewmodels/SimpleViewModel.pbi"

Namespace Demo::Views {

  Class SimpleView Extends UI::Window {

    Public Method Init(*vm.Demo::ViewModels::SimpleViewModel) {
      Super\Init()

      Protected xml.s
      xml + "<Window Title='PureBasic OOP - Simple MVVM' Width='520' Height='340'>"
      xml + "  <DockPanel LastChildFill='true'>"
      xml + "    <StackPanel Dock='Top' Orientation='Vertical' Margin='15,12,15,5'>"
      xml + "      <Label Text='PureBasic OOP - MVVM DataBinding Test' Height='24'/>"
      xml + "    </StackPanel>"
      xml + "    <StackPanel Dock='Bottom' Orientation='Horizontal' Margin='15,5' Height='26'>"
      xml + "      <Label Text='{Binding " + #PROP_STATUS_TEXT + "}' Width='480' Height='20'/>"
      xml + "    </StackPanel>"
      xml + "    <StackPanel Dock='Fill' Orientation='Vertical' Spacing='10' Margin='15,10'>"
      xml + "      <Label Text='Click any button to trigger a ViewModel command:' Height='20'/>"
      xml + "      <StackPanel Orientation='Horizontal' Spacing='10' Height='36'>"
      xml + "        <Button Text='Button 1' Click='" + #CMD_CLICK_BTN1 + "' Width='100' Height='32'/>"
      xml + "        <Button Text='Button 2' Click='" + #CMD_CLICK_BTN2 + "' Width='100' Height='32'/>"
      xml + "        <Button Text='Button 3' Click='" + #CMD_CLICK_BTN3 + "' Width='100' Height='32'/>"
      xml + "        <Button Text='Reset'    Click='" + #CMD_RESET      + "' Width='80'  Height='32'/>"
      xml + "      </StackPanel>"
      xml + "      <Label Text='ViewModel Output (OneWay DataBinding):' Margin='0,5,0,0' Height='20'/>"
      xml + "      <TextBox Text='{Binding " + #PROP_CLICK_MESSAGE + "}' Height='28'/>"
      xml + "      <Label Text='{Binding " + #PROP_TOTAL_CLICKS_TEXT + "}' Margin='0,5,0,0' Height='22'/>"
      xml + "    </StackPanel>"
      xml + "  </DockPanel>"
      xml + "</Window>"

      This\LoadViewFromString(xml, *vm)
    }
  }

}


