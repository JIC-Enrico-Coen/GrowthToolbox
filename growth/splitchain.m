function [ch1,ch2] = splitchain( ch, e1, e2 )
%[ch1,ch2] = splitchain( ch, e1, e2 )
%   CH is the chain of edges and cells around a node of a mesh.  E1 and E2
%   are edges occurring in that chain.  CH1 is set to the subchain from E1
%   to but not including E2, while CH2 is set to the rest of the chain.

    chlen = size(ch,2);
    edges = ch(1,:);
    ch1i = find(edges==e1);
    if e2==0
        zerocells = find( ch(2,:)==0 );
        ch2i = mod( zerocells(1), chlen ) + 1;
    else
        ch2i = find(edges==e2);
    end
    if isempty(ch1i) || isempty(ch2i)
        error('splitchain');
    end
    if ch1i < ch2i
        ch1 = ch( :, ch1i:(ch2i-1) );
        ch2 = ch( :, [ (ch2i:chlen) (1:(ch1i-1)) ] );
    else
        ch2 = ch( :, ch2i:(ch1i-1) );
        ch1 = ch( :, [ (ch1i:chlen) (1:(ch2i-1)) ] );
    end
end
