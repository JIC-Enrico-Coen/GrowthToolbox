function ax = getMeshAxes( m )
%ax = getMeshAxes( m )
%   Return an array of all of the axes in which m is plotted.

    fs = m.pictures(ishandle(m.pictures));
    ax = zeros(1,length(fs));
    for i=1:length(fs)
        h = guidata(fs(i));
        ax(i) = h.picture;
    end
end
