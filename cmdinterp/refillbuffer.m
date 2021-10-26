function tokenstream = refillbuffer( tokenstream )
%tokenstream = refillbuffer( tokenstream )
%   Read a line from the input file and tokenise it.
%   Repeat until at least one token is found or the end of file is reached.

%     if tokenstream.fid == -1, return; end
%     
%     while isempty(tokenstream.tokens)
%         s = fgetl( tokenstream.fid );
%         if iseof( s )
%             fclose( tokenstream.fid );
%             tokenstream.fid = -1;
%             return;
%         end
%         tokenstream.curline = tokenstream.curline+1;
%         tokenstream.tokens = tokeniseString( s );
%     end
    
    while true
        if ~isempty( tokenstream.tokens )
            return;
        elseif tokenstream.fid == -1
            if isempty( tokenstream.stack )
                return;
            elseif length( tokenstream.stack )==1
                tokenstream = tokenstream.stack;
            else
                rest = tokenstream.stack(2:end);
                tokenstream = tokenstream.stack(1);
                if isempty(tokenstream.stack)
                    tokenstream.stack = rest;
                else
                    tokenstream.stack = [ tokenstream.stack, rest ];
                end
            end
        else
            s = fgetl( tokenstream.fid );
            if iseof( s )
                fclose( tokenstream.fid );
                tokenstream.fid = -1;
            else
                tokenstream.curline = tokenstream.curline+1;
                tokenstream.tokens = tokeniseString( s );
                if ~isempty(tokenstream.tokens)
                    return;
                end
            end
        end
    end
end
