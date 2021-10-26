function [State,StC]=SubPhase(realtime,StC,duration,headingstr,counter,iterationcounter)
%To allow subphases to be specified within the interaction function. 
%As each stage is encountered a structure is built that 
%can be used to pass stage specifications to the GFtbox. 
%This then appears on the Stages menu.
%
%realtime, 
% StC the data structure to be elaborated
%duration the time to be spent on this activity
%headingstr, the stage label
%counter, the stage counter. These should start at 1 and increment with
%each call
%iteraction counter, = m.currentiteration used to control initialisation
%
%State, true if realtime lies within this activity
%
%J.Andrew Bangham, 2009

    State=false;
    if iterationcounter<=1 % set up the structure
        if isempty(StC)
            StC=struct;
            StC.N=counter;
            StC.AllHeadingStr{counter}=headingstr;
            StC.NextSubphaseStart(counter)=realtime;
            StC.NextSubphaseStart(counter+1)=StC.NextSubphaseStart(counter)+duration;
        else
            StC.N=counter;
            StC.AllHeadingStr{counter}=headingstr;
            StC.NextSubphaseStart(counter+1)=StC.NextSubphaseStart(counter)+duration;
        end
    else
        if realtime>=StC.NextSubphaseStart(counter) && realtime<StC.NextSubphaseStart(counter+1)
            State=true;
            disp(sprintf('\n>>>>>>> realtime=%5.1f %5d %s\n',realtime,counter,StC.AllHeadingStr{counter}))
        else
            State=false;
        end
    end
end
