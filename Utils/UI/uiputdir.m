function dirname = uiputdir( startpath, defaultname, prompt1, prompt2 )
%dirname = uiputdir( startpath, title )
%   Provide a way for the user to create a new directory.  uigetdir can be
%   used for this purpose, but we have found that users find the resulting
%   dialog confusing.  uiputdir as defined here performs two successive
%   dialogs: the first to obtain a name for the directory that should be
%   created, and the second to select a directory within which to create
%   it.  If the directory to be created already exists, the user will be
%   asked if they want to use it, or to try again with a different name.
%
%   startpath is the directory from which the directory-selection dialog
%   will start.  prompt1 is the prompt displayed in the dialog asking the
%   user for the name of the new directory.  prompt2 is the prompt
%   displayed in the dialog asking the user to select a parent directory.
%   On Mac OS, the latter dialog does not display prompt2 anywhere.
%
%   All arguments are optional.  startpath defaults to the current
%   directory, and prompt1 and prompt2 default to the empty string.

% If we were designing this from scratch, we would use a single dialog
% containing a directory-picker and a field to enter the name of the
% directory we want to create.  This is not possible in Matlab, since there
% is no such thing as a uigetdir GUI widget that might be placed within a
% dialog window.  On both Windows and Mac OS, uigetdir creates a
% platform-native directory picker dialog.

    dirname = '';
    % dirname is subsequently assigned to only immediately before a
    % successful return.
    
    if nargin < 2
        defaultname = '';
    end
    
    if nargin < 3
        prompt1 = '';
    end
    
    if nargin < 4
        prompt2 = '';
    end

    while true
        basename = askForString( defaultname, prompt1 );
        if isempty(basename)
            % User cancelled.
            return;
        end

        parentname = uigetdir( startpath, prompt2 );
        if isempty(parentname)
            % User cancelled.
            return;
        end

        [success,msg,msgid] = mkdir( parentname, basename );
        if success==1
            if isempty(msg)
                % Success.
                dirname = fullfile( parentname, basename );
                return;
            else
                answer = queryDialog( 3, 'Directory already exists', ...
                    'A directory ''%s'' already exists. Use it?', basename );
                switch answer
                    case 1 % Yes
                        dirname = fullfile( parentname, basename );
                        return;
                    case 2 % No, try again
                        continue;
                    case 3 % Cancel
                        return;
                end
            end
        else
            % Could not create.
            answer = queryDialog( 2, 'Cannot create', ...
                'Could not create ''%s'' (%s). Try again?', basename, msgid );
            switch answer
                case 1 % Yes
                    continue;
                case 2 % No, give up
                    return;
            end
        end
    end
end
