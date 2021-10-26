function prepareProjectNameDialog( handle )
    h = guidata( handle );
    c = clock();
    suffix = sprintf( '_%04d%02d%02d', c(1), c(2), c(3) );
    set( h.suffix, 'String', suffix );
    uicontrol( h.basename );
end
