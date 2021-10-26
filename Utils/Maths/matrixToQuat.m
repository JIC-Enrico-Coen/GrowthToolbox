function q = matrixToQuat( m )
%q = matrixToQuat( m )
%   Convert a column rotation matrix to a row quaternion.
%   Code adapted from http://cache-www.intel.com/cd/00/00/29/37/293748_293748.pdf
%   J.M.P. van Waveren "From Quaternion to Matrix and Back"

    trace = m(1,1)+m(2,2)+m(3,3);
    if trace > 0
        t = trace+1;
        s = 0.5/sqrt(t);
        q = s * [ m(3,2) - m(2,3), ...
                  m(1,3) - m(3,1), ...
                  m(2,1) - m(1,2), ...
                  t ];
    elseif (m(1,1) > m(2,2)) && (m(1,1) > m(3,3))
        t = m(1,1)-m(2,2)-m(3,3)+1;
        s = 0.5/sqrt(t);
        q = s * [ t, ...
                  m(2,1) + m(1,2), ...
                  m(1,3) + m(3,1), ...
                  m(3,2) - m(2,3) ];
    elseif m(2,2) > m(3,3)
        t = -m(1,1)+m(2,2)-m(3,3)+1;
        s = 0.5/sqrt(t);
        q = s * [ m(2,1) + m(1,2), ...
                  t, ...
                  m(3,2) + m(2,3), ...
                  m(1,3) - m(3,1) ];
    else
        t = -m(1,1)-m(2,2)+m(3,3)+1;
        s = 0.5/sqrt(t);
        q = s * [ m(1,3) + m(3,1), ...
                  m(3,2) + m(2,3), ...
                  t, ...
                  m(2,1) - m(1,2) ];
    end
end
