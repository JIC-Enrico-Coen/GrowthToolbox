function present = check_menu_bar
% VALUE = CHECK_MENU_BAR
%
% CHECK_MENU_BAR returns true if the integrated menu bar is DISABLED through a 
% JAVA.OPTS file with "-Dapple.laf.useScreenMenuBar=false".

present = false;

% query the arguments to JAVA
RuntimemxBean = java.lang.management.ManagementFactory.getRuntimeMXBean();
list = RuntimemxBean.getInputArguments();

% find the argument for disabled integrated menu bar
indx = strfind(char(list),'-Dapple.laf.useScreenMenuBar=false');
if ~isempty(indx)
    present = true;
end
