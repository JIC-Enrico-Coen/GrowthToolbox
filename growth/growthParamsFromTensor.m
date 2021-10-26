function [ major, minor, theta ] = growthParamsFromTensor( gt )
% Given an N*6 matrix of N growth tensors as row 6-vectors, compute N*1
% arrays of the major growth, minor growth, and angle.  The growth tensors
% are assumed to be given in the plane of the cell, i.e. one principal axis
% is the local z axis.

    symmetrycount = 2;
    xx = gt(:,1);
    yy = gt(:,2);
    xminusysc = gt(:,6)/symmetrycount;
    xplusy = xx+yy;
    xminusyc2 = xx-yy;
    xminusys2 = xminusysc*2;
    theta2 = atan2( xminusys2, xminusyc2 );
    theta = theta2/2;
    xminusy = sqrt( xminusyc2.*xminusyc2 + xminusys2.*xminusys2 );
    x = (xplusy + xminusy)/2;
    y = (xplusy - xminusy)/2;
    major = x;
    minor = y;
    if major < minor
        temp = major;
        major = minor;
        minor = temp;
        theta = theta + pi/2;
    end
end
