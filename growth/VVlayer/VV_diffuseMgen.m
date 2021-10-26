function vvlayer = VV_diffuseMgen( vvlayer, mgenindex, dt )
    mgendiffconsts = vvlayer.diffusion( mgenindex, : ) * dt;

    if mgendiffconsts(1) > 0
        deltaCM = (vvlayer.mgenM(vvlayer.edgeCM(:,2),mgenindex) - vvlayer.mgenC(vvlayer.edgeCM(:,1),mgenindex)) * mgendiffconsts(1);
        vvlayer.mgenC(:,mgenindex) = addallto( vvlayer.mgenC(:,mgenindex), vvlayer.edgeCM(:,1), deltaCM );
        vvlayer.mgenM(:,mgenindex) = addallto( vvlayer.mgenM(:,mgenindex), vvlayer.edgeCM(:,2), -deltaCM );
    end

    if mgendiffconsts(2) > 0
        mgenvalues = vvlayer.mgenM( :, mgenindex );
        totalmgenM1 = VVconvertMconcToCamount( vvlayer, mgenvalues );
        % deltaMM = ((vvlayer.mgenM(vvlayer.edgeMM(:,2),mgenindex) - vvlayer.mgenM(vvlayer.edgeMM(:,1),mgenindex))./seglengthsq) * mgendiffconsts(2);
        deltaMM = ((vvlayer.mgenM(vvlayer.edgeMM(:,2),mgenindex) - vvlayer.mgenM(vvlayer.edgeMM(:,1),mgenindex))./vvlayer.vxLengthsMM) * mgendiffconsts(2);
        delta_mgenM = zeros(size(vvlayer.mgenM,1),1);
        delta_mgenM = addallto( delta_mgenM, vvlayer.edgeMM(:,1), deltaMM );
        delta_mgenM = addallto( delta_mgenM, vvlayer.edgeMM(:,2), -deltaMM );
        delta_mgenM = delta_mgenM ./ vvlayer.vxLengthsM;
        vvlayer.mgenM(:,mgenindex) = vvlayer.mgenM(:,mgenindex) + delta_mgenM;
%         vvlayer.mgenM(:,mgenindex) = addallto( vvlayer.mgenM(:,mgenindex), vvlayer.edgeMM(:,1), deltaMM );
%         vvlayer.mgenM(:,mgenindex) = addallto( vvlayer.mgenM(:,mgenindex), vvlayer.edgeMM(:,2), -deltaMM );
        mgenvalues = vvlayer.mgenM( :, mgenindex );
        totalmgenM2 = VVconvertMconcToCamount( vvlayer, mgenvalues );
        errPerCell = totalmgenM2 - totalmgenM1;
        relerrPerCell = errPerCell./max(abs(totalmgenM1),abs(totalmgenM2));
        maxErrPerCell = max(abs(errPerCell));
        maxRelerrPerCell = max(abs(relerrPerCell));
        sum1 = sum(totalmgenM1);
        sum2 = sum(totalmgenM2);
        err = sum2-sum1;
        relerr = err/max(abs([sum1 sum2]));
        fprintf( 1, 'VV diffusion err %g, relerr %g maxerr %g, maxrelerr %g\n', err, relerr, maxErrPerCell, maxRelerrPerCell );
    end

    if mgendiffconsts(3) > 0
        seglengthsq = (sum( vvlayer.vxLengthsW(vvlayer.edgeWW), 2 )/2).^2;
        deltaWW = ((vvlayer.mgenW(vvlayer.edgeWW(:,2),mgenindex) - vvlayer.mgenW(vvlayer.edgeWW(:,1),mgenindex))./seglengthsq) * mgendiffconsts(3);
        vvlayer.mgenW(:,mgenindex) = addallto( vvlayer.mgenW(:,mgenindex), vvlayer.edgeWW(:,1), deltaWW );
        vvlayer.mgenW(:,mgenindex) = addallto( vvlayer.mgenW(:,mgenindex), vvlayer.edgeWW(:,2), -deltaWW );
    end

    if mgendiffconsts(4) > 0
        deltaWM = (vvlayer.mgenM(vvlayer.edgeWM(:,2),mgenindex) - vvlayer.mgenW(vvlayer.edgeWM(:,1),mgenindex)) * mgendiffconsts(4);
        vvlayer.mgenW(:,mgenindex) = addallto( vvlayer.mgenW(:,mgenindex), vvlayer.edgeWM(:,1), deltaWM );
        vvlayer.mgenM(:,mgenindex) = addallto( vvlayer.mgenM(:,mgenindex), vvlayer.edgeWM(:,2), -deltaWM );
    end

    if mgendiffconsts(5) > 0
        deltaMWM = (vvlayer.mgenM(vvlayer.edgeMWM(:,2),mgenindex) - vvlayer.mgenM(vvlayer.edgeMWM(:,1),mgenindex)) * mgendiffconsts(5);
        vvlayer.mgenM(:,mgenindex) = addallto( vvlayer.mgenM(:,mgenindex), vvlayer.edgeMWM(:,1), deltaMWM );
        vvlayer.mgenM(:,mgenindex) = addallto( vvlayer.mgenM(:,mgenindex), vvlayer.edgeMWM(:,2), -deltaMWM );
    end
end

