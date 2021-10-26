function [rot,trans] = frameChangeMatrix( oldframe, oldorigin, newframe, neworigin )
%

    p1 = neworigin + newframe*oldframe'*(p - oldorigin);
    
    rot = newframe*oldframe';
    trans = neworigin - trans*oldorigin
    
    newframe*oldframe'*p;
    neworigin - newframe*oldframe'*oldorigin);