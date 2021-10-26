function setVisualRunMode( handles, state, h )
%setVisualRunMode( handles, state, h )
%   h is the handle of a button or text item for the Run To, Run For, Run
%   Until, or Step buttons or text items.
%   handles is the GUI handles structure.
%   state is either 'idle', 'running', or 'completed'.
%   The background color of h is set to white, yellow, or green
%   respectively, as is the other text item or button associated with h, if
%   any. All other handles are set to white.
%   If h is omitted, so also can state be; all the handles will be set to
%   the idle colour.

    if isempty(handles)
        handles = getGFtboxHandles();
        if isempty(handles)
            return;
        end
    end
    
    colors = [1 1 1;
              1 1 0.5;
              0.5 1 0.65];
    tags = { 'runUntilButton' 'simtimeText' 'run' 'simsteps' 'runToButton' 'areaTargetText' 'singlestep', 'initialiseIFButton' };
    states = ones(1,length(tags));

    if nargin < 3
        tag = '';
    elseif ischar(h)
        tag = h;
    elseif isfield( h, 'Tag' )
        tag = h.Tag;
    else
        tag = '';
    end
    
    if nargin >= 3
        switch state
            case 'idle'
                state = 1;
            case 'running'
                state = 2;
            case 'completed'
                state = 3;
            otherwise
                state = 1;
        end

        switch tag
            case 'runUntilButton' % Run Until (time)
               states([1 2]) = state;

            case 'run' % Run For (steps)
               states([3 4]) = state;

            case 'runToButton' % Run To (area)
               states([5 6]) = state;

            case 'singlestep' % Step
               states(7) = state;

            case 'initialiseIFButton' % Step
               states(8) = state;
        end
    end
    
    for i=1:length(states)
        if isfield( handles, tags{i} )
            h1 = handles.(tags{i});
            switch h1.Style
                case { 'edit' 'pushbutton' }
                    bgcolor = colors(states(i),:);
                    set(h1,'BackgroundColor',bgcolor);
                    if isfield( h1.UserData, 'BackgroundColor' )
                        h1.UserData.BackgroundColor = bgcolor;
                    end
            end
        end
    end
end
