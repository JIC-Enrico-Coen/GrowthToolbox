function testrkmesh(n)
%TESTRKMESH(N)  Run RKMESH with a predefined set of arguments.
switch n,
    case 0,
        fprintf( 1, 'Option %d: Very low hinge strength, growth on circumference.%c', n, 10 );
        rkmesh(30.000,0.200,'growth','radial',0.100, ...
            [7.000,2.000,0.020],10,0,4,0.10,0.50,1,'','');
    case 1,
        fprintf( 1, 'Option %d: Low hinge strength, growth on circumference.%c', n, 10 );
        rkmesh(30.000,0.200,'growth','radial',0.100, ...
            [7.000,2.000,0.005],5,0,4,0.10,0.50,1,'','');
    case 2,
        fprintf( 1, 'Option %d: Medium hinge strength, growth on circumference.%c', n, 10 );
        rkmesh(30.000,0.200,'growth','radial',0.100, ...
            [7.000,2.000,0.01],5,0,4,0.10,0.50,1,'','');
    case 3,
        fprintf( 1, 'Option %d: High hinge strength, growth on circumference.%c', n, 10 );
        rkmesh(30.000,0.200,'growth','radial',0.100, ...
            [7.000,2.000,0.015],5,0,4,0.10,0.50,1,'','');
    case 4,
        fprintf( 1, 'Option %d: Very high hinge strength, growth on circumference.%c', n, 10 );
        rkmesh(30.000,0.200,'growth','radial',0.100, ...
            [7.000,2.000,0.02],5,0,4,0.10,0.50,1,'','');
    case 5,
        fprintf( 1, 'Option %d: Very high hinge strength, growth on one edge.%c', n, 10 );
        rkmesh(1.000,0.200,'growth','edge',0.100, ...
            [7.000,4.000,0.02],10,0,4,0.10,0.50,1,'','');
    case 6,
        fprintf( 1, 'Option %d: Very high hinge strength, growth on circumference.%c', n, 10 );
        rkmesh(5.000,0.200,'growth','radial',0.200, ...
            [7.000,4.000,0.02],10,0,4,0.10,0.50,1,'','');
    case 7,
        fprintf( 1, 'Option %d: Very high hinge strength, growth in centre.%c', n, 10 );
        rkmesh(5.000,0.200,'growth','radial',-0.200, ...
            [7.000,4.000,0.01],10,0,4,0.10,0.50,1,'','');
    case 8,
        fprintf( 1, 'Option %d%c', n, 10 );
        rkmesh(5.000,0.200,'growth','radial',0.200, ...
            [7.000,4.000,0.01],10,0,4,0.10,0.50,1,'','edge');
        rkmesh(5.000,0.200,'growth','radial',-0.200, ...
            [7.000,4.000,0.01],10,0,4,0.10,0.50,1,'','centre');
        rkmesh(5.000,0.200,'growth','edge',0.100, ...
            [7.000,4.000,0.01],10,0,4,0.10,0.50,1,'','edgept');
    case 9,
        fprintf( 1, 'Option %d%c', n, 10 );
        rkmesh(10.000,0.200,'growth','radial',-0.200, ...
            [7.000,4.000,0.01],10,0,3,0.10,0.50,1,'','');
    otherwise,
        fprintf( 1, 'testrkmesh: argument must be in the range 1..3.%c', 10 );
end
end
