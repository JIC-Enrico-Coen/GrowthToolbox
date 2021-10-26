function initialiseGFtboxGuiTypes( h )
%initialiseGFtboxGuiTypes( h )
%   This installs userdata into every GFtbox gui item that needs it, to
%   specify the type of data, if any, the item contains.  This is only
%   required for those items that either might or might not be intended to
%   return a value, or might return a value of more than one type.
%
%   getGuiItemValue uses this information to decide what value to return.
%
%   By default a checkbox, toggle button, or radio button returns a logical
%   value.  Otherwise datainfo should contain whatever value is to be
%   returned when the item is checked/on/selected.  In the opposite state
%   it will return [].
%
%   Editable text items by default return a string.  datainfo may specify
%   that the value be converted to integer or floating point.
%
%   Static text items are like editable text items, except that by default
%   they return nothing unless datainfo is set.
%
%   Sliders return double unless datainfo is 'int32'.
%
%   Popup menus by default return the index of the selected item, unless
%   datainfo is 'char', in which case they return the label of the
%   selected item.
%
%   Panels return nothing except when datainfo is 'color', when they return
%   their background colour.  This is used for coloured panels that invoke
%   color pickers when clicked.
%
%   All other types of gui item return nothing, unless datainfo is set, and
%   then they return the value of datainfo.
%
%   See also: getGuiItemValue.

    initialiseGuiUserData( h, ...
        'color', { 'cellColorIndicator1', ...
                   'cellColorIndicator2', ...
                   'mgenColorChooser', ...
                   'mgenNegColorChooser', ...
                   'VVmgenColorChooser', ...
                   'VVmgenNegColorChooser', ...
                 }, ...
        'double', { 'scalebar', ...
                    'bioArefinement', ...
                    'bioAaxisratiotext', ...
                    'colorVariationText', ...
                    'bioArelsizetext', ...
                    'diffusionToleranceText', ...
                    'splitmargintext', ...
                    'maxsolvetime', ...
                    'solvertolerance', ...
                    'minpolgradText', ...
                    'edgesplitscaletext', ...
                    'maxBendtext', ...
                    'absorptionText', ...
                    'conductivityText', ...
                    'linearDirection', ...
                    'radialz', ...
                    'radialy', ...
                    'radialx', ...
                    'paintamount', ...
                    'vvmgenamount', ...
                    'shockAtext', ...
                    'bioApointsizeText', ...
                    'bioAlinesizeText', ...
                    'brushsizeText', ...
                    'autoColorRangeMidtext', ...
                    'multiBrightenText', ...
                    'sparsityText', ...
                    'dclipText', ...
                    'elclipText', ...
                    'azclipText', ...
                    'autoColorRangeMaxtext', ...
                    'autoColorRangeMintext', ...
                    'poissonsRatio', ...
                    'simtimeText', ...
                    'areaTargetText', ...
                    'timestep', ...
                    'freezetext', ...
                    'mutanttext', ...
                    'thicknessText', ...
                    'offsetText', ...
                    'rotatetext', ...
                    'zamount', ...
                    'geomparam33', ...
                    'geomparam23', ...
                    'geomparam13', ...
                    'geomparam32', ...
                    'geomparam22', ...
                    'geomparam12', ...
                    'geomparam31', ...
                    'geomparam21', ...
                    'geomparam11', ...
                    'refineproptext', ...
                  }, ...
        'int32', { 'vvsegsperedgetext', ...
                   'numvvcellstext', ...
                   'bioArefinement', ...
                   'actualBioACellsStatictext', ...
                   'maxBioAtext', ...
                   'cellSidesText', ...
                   'actualBioACellstext', ...
                   'totalCellsText', ...
                   'maxFEtext', ...
                   'simsteps', ...
                   'numsaddle', ...
                 }, ...
        'char', { 'colornamelo', ...
                  'colornamehi', ...
                  'colortitle', ...
                  'report', ...
                  'dateItem', ...
                  'siminfoText', ...
                  'legend', ...
                  'growingText', ...
                  'rolltext', ...
                  'elevationtext', ...
                  'azimuthtext', ...
                }, ...
        'logical', { 'timeCommandsItem', ...
                    'catchIFExceptionsItem', ...
                    'staticReadOnlyItem', ...
                    'alwaysRectifyVerticalsItem', ...
                    'allowSparseItem', ...
                    'enabledisableIFitem', ...
                    'useGraphicsCardItem', ...
                    'useprevdispItem', ...
                    'stripsaveItem', ...
                    'RecordMeshes', ...
                    'autonameItem', ...
                    'FENumbersItem', ...
                    'edgeNumbersItem', ...
                    'nodeNumbersItem', ...
                    'lineSmoothingItem', ...
                    'lightMenuItem', ...
                    'staticDecorItem', ...
                    'cellsonbothsidesItem', ...
                    'normalsMenuItem', ...
                    'displacementsMenuItem', ...
                    'colorbarMenuItem', ...
                    'axesMenuItem', ...
                    'vvMenuItem', ...
                    'seamsMenuItem', ...
                    'thicknessMenuItem', ...
                    'showmeshMenuItem', ...
                    'scalebarMenuItem', ...
                    'legendMenuItem', ...
                    'autocentreItem', ...
                    'autozoomItem', ...
                    'autozoomcentreItem', ...
                    'resetZoomCentreItem', ...
                    'whiteMenuItem', ...
                    'blackMenuItem', ...
                    'maxabsErrorItem', ...
                    'normErrorItem', ...
                    'culaSgesvSolverItem', ...
                    'lsqrSolverItem', ...
                    'cgsSolverItem', ...
                    'doublePrecisionItem', ...
                    'singlePrecisionItem', ...
                    'MotionJPEG2000Item', ...
                    'UncompressedAVIItem', ...
                    'ArchivalItem', ...
                    'MPEG4Item', ...
                    'MotionJPEGAVIItem', ...
                    'noneRendererItem', ...
                    'paintersRendererItem', ...
                    'zbuggerRendererItem', ...
                    'openGLRendererItem', ...
                   }, ...
        'max', { 'splitMgenMaxButton' }, ...
        'min', { 'splitMgenMinButton' }, ...
        'mid', { 'splitMgenAverageButton' } );
end



%{
                  GFTwindow       *        Figure      char  '(matlab.ui.Figure)'
                  aboutMenu       *          Menu      char  '(matlab.ui.container.Menu)'
                colornamelo                  text      char  ''
                colornamehi                  text      char  ''
                 colortitle                  text      char  ''
               vvlayerpanel       *         Panel      char  '(matlab.ui.container.Panel)'
                   scalebar                  text    double  0.5
                   rolltext                  text      char  'ro:0.00'
              elevationtext                  text      char  'el:33.75'
                azimuthtext                  text      char  'az:-45.00'
           resetViewControl       *         Panel      char  '(matlab.ui.container.Panel)'
            rollzeroControl       *         Panel      char  '(matlab.ui.container.Panel)'
                       roll                slider    double  0
                       help       *          Menu      char  '(matlab.ui.container.Menu)'
                   miscMenu       *          Menu      char  '(matlab.ui.container.Menu)'
                 stagesMenu       *          Menu      char  '(matlab.ui.container.Menu)'
                  movieMenu       *          Menu      char  '(matlab.ui.container.Menu)'
                   plotMenu       *          Menu      char  '(matlab.ui.container.Menu)'
                  junkPanel       *         Panel      char  '(matlab.ui.container.Panel)'
                  bio1panel       *         Panel      char  '(matlab.ui.container.Panel)'
                 paramsMenu       *          Menu      char  '(matlab.ui.container.Menu)'
                colortextlo                  text      char  ''
                colortexthi                  text      char  ''
                   meshMenu       *          Menu      char  '(matlab.ui.container.Menu)'
                  mainpanel       *         Panel      char  '(matlab.ui.container.Panel)'
                     report                  text      char  'WILDTYPE  96 FEs, 61 vertexes. Step 0, 0.000 s.                                           Growth: area 1.00, linear 1.00. Strain max 0.00% average 0.00%. Av. strain retention 0%.  '
                  elevation                slider    double  -33.75
                    azimuth                slider    double  45
                runsimpanel       *         Panel      char  '(matlab.ui.container.Panel)'
               picturepanel       *         Panel      char  '(matlab.ui.container.Panel)'
               projectsMenu       *          Menu      char  '(matlab.ui.container.Menu)'
             morphdistpanel       *         Panel      char  '(matlab.ui.container.Panel)'
                 deadcanary       *          text      char  '(matlab.ui.control.UIControl)'
         growthtensorspanel       *         Panel      char  '(matlab.ui.container.Panel)'
                 pictureOLD       *          Axes      char  '(matlab.graphics.axis.Axes)'
                   colorbar       *          Axes      char  '(matlab.graphics.axis.Axes)'
                   dateItem                  Menu      char  '2018-04-17 17:30'
                  uipanel95       *         Panel      char  '(matlab.ui.container.Panel)'
                    text132       *          text      char  '(matlab.ui.control.UIControl)'
                    text131       *          text      char  '(matlab.ui.control.UIControl)'
                    text130       *          text      char  '(matlab.ui.control.UIControl)'
          vvsegsperedgetext                  edit     int32  3
             numvvcellstext                  edit     int32  []
               makevvbutton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
           timeCommandsItem                  Menu   logical  false
      catchIFExceptionsItem                  Menu   logical  true
              errorTypeMenu       *          Menu      char  '(matlab.ui.container.Menu)'
                 solverItem       *          Menu      char  '(matlab.ui.container.Menu)'
              precisionItem       *          Menu      char  '(matlab.ui.container.Menu)'
         staticReadOnlyItem                  Menu   logical  false
 alwaysRectifyVerticalsItem                  Menu   logical  false
            allowSparseItem                  Menu   logical  true
        enabledisableIFitem                  Menu   logical  true
           validateMeshItem       *          Menu      char  '(matlab.ui.container.Menu)'
        useGraphicsCardItem                  Menu   logical  false
           hiresOptionsItem       *          Menu      char  '(matlab.ui.container.Menu)'
            useprevdispItem                  Menu   logical  true
              stripsaveItem                  Menu   logical  false
                  GUIformat       *          Menu      char  '(matlab.ui.container.Menu)'
              thumbnailItem       *          Menu      char  '(matlab.ui.container.Menu)'
            movieStagesItem       *          Menu      char  '(matlab.ui.container.Menu)'
               RecordMeshes                  Menu   logical  false
                 gyrateItem       *          Menu      char  '(matlab.ui.container.Menu)'
                   tiltItem       *          Menu      char  '(matlab.ui.container.Menu)'
                   spinItem       *          Menu      char  '(matlab.ui.container.Menu)'
                  codecMenu       *          Menu      char  '(matlab.ui.container.Menu)'
     compressionQualityItem       *          Menu      char  '(matlab.ui.container.Menu)'
              frameRateItem       *          Menu      char  '(matlab.ui.container.Menu)'
               addFrameItem       *          Menu      char  '(matlab.ui.container.Menu)'
               autonameItem                  Menu   logical  true
               rendererMenu       *          Menu      char  '(matlab.ui.container.Menu)'
              FENumbersItem                  Menu   logical  false
            edgeNumbersItem                  Menu   logical  false
            nodeNumbersItem                  Menu   logical  false
                 stereoItem       *          Menu      char  '(matlab.ui.container.Menu)'
           canvasColorsItem       *          Menu      char  '(matlab.ui.container.Menu)'
          lineSmoothingItem                  Menu   logical  true
                opacityItem       *          Menu      char  '(matlab.ui.container.Menu)'
                ambientItem       *          Menu      char  '(matlab.ui.container.Menu)'
              lightMenuItem                  Menu   logical  false
            staticDecorItem                  Menu   logical  true
       cellsonbothsidesItem                  Menu   logical  true
            normalsMenuItem                  Menu   logical  false
      displacementsMenuItem                  Menu   logical  false
           colorbarMenuItem                  Menu   logical  false
               axesMenuItem                  Menu   logical  false
                 vvMenuItem                  Menu   logical  false
              seamsMenuItem                  Menu   logical  false
          thicknessMenuItem                  Menu   logical  false
           showmeshMenuItem                  Menu   logical  false
          scalebarscaleItem       *          Menu      char  '(matlab.ui.container.Menu)'
           scalebarMenuItem                  Menu   logical  false
              setLegendItem       *          Menu      char  '(matlab.ui.container.Menu)'
             legendMenuItem                  Menu   logical  false
             autocentreItem                  Menu   logical  false
               autozoomItem                  Menu   logical  false
         autozoomcentreItem                  Menu   logical  false
        resetZoomCentreItem                  Menu   logical  false
                useviewItem       *          Menu      char  '(matlab.ui.container.Menu)'
                setviewItem       *          Menu      char  '(matlab.ui.container.Menu)'
 defaultViewFromCurrentItem       *          Menu      char  '(matlab.ui.container.Menu)'
              whiteMenuItem                  Menu   logical  true
              blackMenuItem                  Menu   logical  false
                makefigItem       *          Menu      char  '(matlab.ui.container.Menu)'
            makecaptionItem       *          Menu      char  '(matlab.ui.container.Menu)'
         multiplotcellsItem       *          Menu      char  '(matlab.ui.container.Menu)'
              multiplotItem       *          Menu      char  '(matlab.ui.container.Menu)'
                 replotItem       *          Menu      char  '(matlab.ui.container.Menu)'
                    runFlag              checkbox   logical  false
            initialisePanel       *         Panel      char  '(matlab.ui.container.Panel)'
            splitBioAbutton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                   stopFlag              checkbox   logical  false
                   plotFlag              checkbox   logical  true
                commandFlag              checkbox   logical  false
                flipTCPanel       *         Panel      char  '(matlab.ui.container.Panel)'
                 bioArefine       *    pushbutton      char  '(matlab.ui.control.UIControl)'
             bioArefinement                  edit     int32  1
                    text145       *          text      char  '(matlab.ui.control.UIControl)'
          mouseCellModeMenu             popupmenu     int32  1
        bioAuniversalbutton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
   allowbiooveredgeCheckbox              checkbox   logical  true
          bioAaxisratiotext                  edit    double  1
                    text127       *          text      char  '(matlab.ui.control.UIControl)'
    allowbiooverlapCheckbox              checkbox   logical  true
           bioAsinglebutton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
  actualBioACellsStatictext                  text     int32  []
              shockbioPanel       *         Panel      char  '(matlab.ui.container.Panel)'
             bioAgridbutton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
          bioAscatterbutton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
        cellColorIndicator2                 Panel    double  [1 0.1 0.1]
         colorVariationText                  edit    double  0.05
                     text88       *          text      char  '(matlab.ui.control.UIControl)'
                     text87       *          text      char  '(matlab.ui.control.UIControl)'
        cellColorIndicator1                 Panel    double  [0.1 1 0.1]
                     text86       *          text      char  '(matlab.ui.control.UIControl)'
                maxBioAtext                  edit     int32  0
            graphicbioPanel       *         Panel      char  '(matlab.ui.container.Panel)'
            bioArelsizetext                  edit    double  0.02
                     text82       *          text      char  '(matlab.ui.control.UIControl)'
        bioAsplitTypeSelect       *   ButtonGroup      char  '(matlab.ui.container.ButtonGroup)'
        cellSidesStaticText       *          text      char  '(matlab.ui.control.UIControl)'
              cellSidesText                  edit     int32  12
        actualBioACellstext                  edit     int32  20
             bioAfillbutton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
           bioAdeletebutton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
  simplifySecondLayerButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                     text66       *          text      char  '(matlab.ui.control.UIControl)'
             totalCellsText                  edit     int32  0
                rescaleItem       *          Menu      char  '(matlab.ui.container.Menu)'
               distunititem       *          Menu      char  '(matlab.ui.container.Menu)'
               timeunitItem       *          Menu      char  '(matlab.ui.container.Menu)'
                   meshToVV       *          Menu      char  '(matlab.ui.container.Menu)'
             importMeshItem       *          Menu      char  '(matlab.ui.container.Menu)'
             exportMeshItem       *          Menu      char  '(matlab.ui.container.Menu)'
    rectifyVerticalsNowItem       *          Menu      char  '(matlab.ui.container.Menu)'
         multiplyLayersItem       *          Menu      char  '(matlab.ui.container.Menu)'
                savefigItem       *          Menu      char  '(matlab.ui.container.Menu)'
                savestlitem       *          Menu      char  '(matlab.ui.container.Menu)'
               savevrmlItem       *          Menu      char  '(matlab.ui.container.Menu)'
                saveMSRItem       *          Menu      char  '(matlab.ui.container.Menu)'
                savedaeItem       *          Menu      char  '(matlab.ui.container.Menu)'
                saveobjItem       *          Menu      char  '(matlab.ui.container.Menu)'
                savematItem       *          Menu      char  '(matlab.ui.container.Menu)'
                loadMSRItem       *          Menu      char  '(matlab.ui.container.Menu)'
                loadobjItem       *          Menu      char  '(matlab.ui.container.Menu)'
             loadscriptItem       *          Menu      char  '(matlab.ui.container.Menu)'
                loadmatItem       *          Menu      char  '(matlab.ui.container.Menu)'
                  uipanel98       *         Panel      char  '(matlab.ui.container.Panel)'
            cellmgens_panel       *    pushbutton      char  '(matlab.ui.control.UIControl)'
      displayedCellMgenMenu             popupmenu     int32  1
       cellMgenSelectButton              checkbox   logical  false
                    text136       *          text      char  '(matlab.ui.control.UIControl)'
        displayedGrowthMenu             popupmenu     int32  1
        newplotQuantityMenu             popupmenu     int32  1
         tensorPropertyMenu             popupmenu     int32  1
             showTensorAxes              checkbox   logical  false
         outputSelectButton              checkbox   logical  false
          inputSelectButton              checkbox   logical  true
                  busyPanel       *         Panel      char  '(matlab.ui.container.Panel)'
                   snapshot       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                  plotPanel       *         Panel      char  '(matlab.ui.container.Panel)'
           interactionPanel       *         Panel      char  '(matlab.ui.container.Panel)'
                editorpanel       *         Panel      char  '(matlab.ui.container.Panel)'
                movieButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                resetButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
              savemodelover       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                reloadmodel       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                   runPanel       *         Panel      char  '(matlab.ui.container.Panel)'
              restartButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                    text126       *          text      char  '(matlab.ui.control.UIControl)'
                 toolSelect       *   ButtonGroup      char  '(matlab.ui.container.ButtonGroup)'
     outputSelectStaticText       *          text      char  '(matlab.ui.control.UIControl)'
      inputSelectStaticText       *          text      char  '(matlab.ui.control.UIControl)'
              thumbnailAxes       *          Axes      char  '(matlab.graphics.axis.Axes)'
    simulationMouseModeMenu             popupmenu     int32  1
            relativepolgrad              checkbox   logical  false
          diffTolStaticText       *          text      char  '(matlab.ui.control.UIControl)'
     diffusionToleranceText                  edit    double  1e-05
              flattenButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
            splitmargintext                  edit    double  1.4
                    text109       *          text      char  '(matlab.ui.control.UIControl)'
                     text93       *          text      char  '(matlab.ui.control.UIControl)'
               maxsolvetime                  edit    double  1000
         elastTolStaticText       *          text      char  '(matlab.ui.control.UIControl)'
            solvertolerance                  edit    double  0.001
             minpolgradText                  edit    double  0
                     text90       *          text      char  '(matlab.ui.control.UIControl)'
              explodeButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
              dissectButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
         edgesplitscaletext                  edit    double  0
                     text76       *          text      char  '(matlab.ui.control.UIControl)'
                maxBendtext                  edit    double  0.3
                     text75       *          text      char  '(matlab.ui.control.UIControl)'
                  maxFEtext                  edit     int32  0
                     text65       *          text      char  '(matlab.ui.control.UIControl)'
                siminfoText                  text      char  ''
             timescalePanel       *         Panel      char  '(matlab.ui.container.Panel)'
                freezePanel       *         Panel      char  '(matlab.ui.container.Panel)'
                 flatstrain       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                   destrain       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                  uipanel26       *         Panel      char  '(matlab.ui.container.Panel)'
                     legend                  text      char  'time 0.000: KAPAR'
                    picture       *          Axes      char  '(matlab.graphics.axis.Axes)'
          pictureBackground       *          Axes      char  '(matlab.graphics.axis.Axes)'
        refreshProjectsMenu       *          Menu      char  '(matlab.ui.container.Menu)'
      addProjectsFolderItem       *          Menu      char  '(matlab.ui.container.Menu)'
           purgeProjectItem       *          Menu      char  '(matlab.ui.container.Menu)'
      showProjectFolderItem       *          Menu      char  '(matlab.ui.container.Menu)'
          saveProjectAsItem       *          Menu      char  '(matlab.ui.container.Menu)'
           closeProjectItem       *          Menu      char  '(matlab.ui.container.Menu)'
            openProjectItem       *          Menu      char  '(matlab.ui.container.Menu)'
                    text141       *          text      char  '(matlab.ui.control.UIControl)'
                    text140       *          text      char  '(matlab.ui.control.UIControl)'
          morpheditmodemenu             popupmenu     int32  1
                    text129       *          text      char  '(matlab.ui.control.UIControl)'
        mgenNegColorChooser                 Panel    double  [0 1 1]
                    text128       *          text      char  '(matlab.ui.control.UIControl)'
           mgenColorChooser                 Panel    double  [1 0 0]
       splitMgenButtonGroup       *   ButtonGroup      char  '(matlab.ui.container.ButtonGroup)'
            allfactorsPanel       *         Panel      char  '(matlab.ui.container.Panel)'
              allowDilution              checkbox   logical  false
                     text59       *          text      char  '(matlab.ui.control.UIControl)'
                     text15       *          text      char  '(matlab.ui.control.UIControl)'
             absorptionText                  edit    double  0
           conductivityText                  edit    double  0
              mutationPanel       *         Panel      char  '(matlab.ui.container.Panel)'
               invertGrowth       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                     text45       *          text      char  '(matlab.ui.control.UIControl)'
                     text44       *          text      char  '(matlab.ui.control.UIControl)'
                     text43       *          text      char  '(matlab.ui.control.UIControl)'
                     text42       *          text      char  '(matlab.ui.control.UIControl)'
            linearDirection                  edit    double  0
               linearGrowth       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                    radialz                  edit    double  0
                    radialy                  edit    double  0
                    radialx                  edit    double  0
                   gfradial       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                 edgeGrowth       *    pushbutton      char  '(matlab.ui.control.UIControl)'
               randomGrowth       *    pushbutton      char  '(matlab.ui.control.UIControl)'
             constantGrowth       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                     text39       *          text      char  '(matlab.ui.control.UIControl)'
                paintamount                  edit    double  1
                paintslider                slider    double  1
                     zerogf       *    pushbutton      char  '(matlab.ui.control.UIControl)'
           renameMgenButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
           deleteMgenButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
              newMgenButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
           loadGrowthButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                    text135       *          text      char  '(matlab.ui.control.UIControl)'
               vvmgenamount                  edit    double  1
               vvmgenslider                slider    double  1
         selectedVVmgenmenu             popupmenu     int32  1
                    text134       *          text      char  '(matlab.ui.control.UIControl)'
      VVmgenNegColorChooser                 Panel    double  [0.6952 0.91808 0.6952]
                    text133       *          text      char  '(matlab.ui.control.UIControl)'
         VVmgenColorChooser                 Panel    double  [0.6952 0.91808 0.6952]
      addrandomVVmgenbutton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
       addconstVVmgenbutton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
        setzeroVVmgenbutton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
         renameVVmgenbutton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
         deleteVVmgenbutton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
            newVVmgenbutton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
            maxabsErrorItem                  Menu   logical  true
              normErrorItem                  Menu   logical  false
        culaSgesvSolverItem                  Menu   logical  false
             lsqrSolverItem                  Menu   logical  false
              cgsSolverItem                  Menu   logical  true
        doublePrecisionItem                  Menu   logical  true
        singlePrecisionItem                  Menu   logical  false
         MotionJPEG2000Item                  Menu   logical  false
        UncompressedAVIItem                  Menu   logical  false
               ArchivalItem                  Menu   logical  false
                  MPEG4Item                  Menu   logical  true
          MotionJPEGAVIItem                  Menu   logical  false
           noneRendererItem                  Menu   logical  false
       paintersRendererItem                  Menu   logical  false
        zbuggerRendererItem                  Menu   logical  false
         openGLRendererItem                  Menu   logical  true
            viewObliqueItem       *          Menu      char  '(matlab.ui.container.Menu)'
         viewFromMinusZItem       *          Menu      char  '(matlab.ui.container.Menu)'
         viewFromMinusYItem       *          Menu      char  '(matlab.ui.container.Menu)'
          viewFromPlusYItem       *          Menu      char  '(matlab.ui.container.Menu)'
         viewFromMinusXItem       *          Menu      char  '(matlab.ui.container.Menu)'
          viewFromPlusXItem       *          Menu      char  '(matlab.ui.container.Menu)'
          viewFromPlusZItem       *          Menu      char  '(matlab.ui.container.Menu)'
                     text79       *          text      char  '(matlab.ui.control.UIControl)'
       editMgenInitfnButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                growingText                  text      char  ''
                unshockBioA       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                 shockAtext                  edit    double  0.1
               shockAslider                slider    double  0.1
            bioAshockbutton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
          bioAuniformButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
           bioAcolorsButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
          bioApointsizeText                  edit    double  0
                     text85       *          text      char  '(matlab.ui.control.UIControl)'
           bioAlinesizeText                  edit    double  2
                     text83       *          text      char  '(matlab.ui.control.UIControl)'
       bioAsplitEdgesButton           radiobutton   logical  false
       bioAsplitCellsButton           radiobutton   logical  true
              brushsizeText                  edit    double  0.1
       clearSelectionButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
     mouseClickVertexButton          togglebutton   logical  true
       mouseClickEdgeButton          togglebutton   logical  false
       mouseClickFaceButton          togglebutton   logical  false
       mouseClickIconButton          togglebutton   logical  true
         mouseBoxIconButton          togglebutton   logical  false
       mouseBrushIconButton          togglebutton   logical  false
                     text92       *          text      char  '(matlab.ui.control.UIControl)'
                    text144       *          text      char  '(matlab.ui.control.UIControl)'
      autoColorRangeMidtext                  edit    double  []
        colorScalePopupMenu             popupmenu     int32  4
         allowSnapsCheckbox              checkbox   logical  true
         enablePlotCheckbox              checkbox   logical  true
 axisRangeFromPictureButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
          multiBrightenText                  edit    double  0.1
             drawmulticolor              checkbox   logical  false
             clipmgenButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
         clipbymgenCheckbox              checkbox   logical  false
         sparsityStaticText       *          text      char  '(matlab.ui.control.UIControl)'
               sparsityText                  edit    double  0
           rotuprightToggle          togglebutton   logical  false
               clipCheckbox              checkbox   logical  false
                  dclipText                  edit    double  -0.01
                 elclipText                  edit    double  0
                    text107       *          text      char  '(matlab.ui.control.UIControl)'
                    text106       *          text      char  '(matlab.ui.control.UIControl)'
                    text105       *          text      char  '(matlab.ui.control.UIControl)'
                 azclipText                  edit    double  0
            showSecondLayer              checkbox   logical  true
              showPolariser              checkbox   logical  false
             showPolariser2              checkbox   logical  false
             showPolariser3              checkbox   logical  false
     showNoEdgesRadioButton           radiobutton   logical  false
   showSomeEdgesRadioButton           radiobutton   logical  true
    showAllEdgesRadioButton           radiobutton   logical  false
      autoColorRangeMaxtext                  edit    double  0
                     text81       *          text      char  '(matlab.ui.control.UIControl)'
                     text80       *          text      char  '(matlab.ui.control.UIControl)'
                     text62       *          text      char  '(matlab.ui.control.UIControl)'
               rotateToggle          togglebutton   logical  true
                 zoomToggle          togglebutton   logical  false
                  panToggle          togglebutton   logical  false
                  autoScale              checkbox   logical  true
      autoColorRangeMintext                  edit    double  0
             autoColorRange              checkbox   logical  true
               bsideRButton           radiobutton   logical  true
               asideRButton           radiobutton   logical  false
               enableIFtext       *          text      char  '(matlab.ui.control.UIControl)'
            rewriteIFButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                notesButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
         initialiseIFButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
  editMgenInteractionButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
        mgenInteractionName       *          text      char  '(matlab.ui.control.UIControl)'
          mouseeditmodeMenu             popupmenu     int32  1
        thicknessRadioGroup       *   ButtonGroup      char  '(matlab.ui.container.ButtonGroup)'
            rotatemeshPanel       *         Panel      char  '(matlab.ui.container.Panel)'
               modifyZPanel       *         Panel      char  '(matlab.ui.container.Panel)'
               newMeshPanel       *         Panel      char  '(matlab.ui.container.Panel)'
      flipOrientationButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
             unfixallButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                    fixZbox              checkbox   logical  true
                    fixYbox              checkbox   logical  true
                    fixXbox              checkbox   logical  true
                 alwaysFlat              checkbox   logical  false
                       twoD              checkbox   logical  false
              poissonsRatio                  edit    double  0.3
                     text25       *          text      char  '(matlab.ui.control.UIControl)'
                  rotateXYZ       *    pushbutton      char  '(matlab.ui.control.UIControl)'
            refinemeshPanel       *         Panel      char  '(matlab.ui.container.Panel)'
             areaStaticText       *          text      char  '(matlab.ui.control.UIControl)'
             timeStaticText       *          text      char  '(matlab.ui.control.UIControl)'
                 stopButton           radiobutton   logical  false
                 singlestep       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                simtimeText                  edit    double  0
             runUntilButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
         numStepsStaticText       *          text      char  '(matlab.ui.control.UIControl)'
             areaTargetText                  edit    double  1
                runToButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                   simsteps                  edit     int32  10
                        run       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                    vvlayer           radiobutton   logical  false
              growthtensors           radiobutton   logical  false
                       bio1           radiobutton   logical  false
                     runsim           radiobutton   logical  true
                  morphdist           radiobutton   logical  false
                     editor           radiobutton   logical  false
                   timestep                  edit    double  0.01
                 freezetext                  edit    double  0
               freezeslider                slider    double  0
          usefrozengradient              checkbox   logical  true
             allowFlipEdges              checkbox   logical  false
        allowNegativeGrowth              checkbox   logical  true
         allowRetriangulate              checkbox   logical  true
          allowSplitBentFEM              checkbox   logical  false
           useGrowthTensors              checkbox   logical  false
              allowSplitBio              checkbox   logical  true
          allowSplitLongFEM              checkbox   logical  true
           diffusionEnabled              checkbox   logical  true
       plasticGrowthEnabled              checkbox   logical  false
       springyGrowthEnabled              checkbox   logical  false
              growthEnabled              checkbox   logical  true
         splitMgenMaxButton           radiobutton   logical  false
         splitMgenMinButton           radiobutton   logical  false
     splitMgenAverageButton           radiobutton   logical  true
            allWildcheckbox              checkbox   logical  false
                    zeroall       *    pushbutton      char  '(matlab.ui.control.UIControl)'
         revertMutantButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                 mutanttext                  edit    double  1
               mutantslider                slider    double  1
              thicknessText                  edit    double  []
                 offsetText                  edit    double  []
            thicknessButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
          directRadioButton           radiobutton   logical  false
        physicalRadioButton           radiobutton   logical  true
        rotateNegMeshButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                 rotatetext                  edit    double  45
               rotateslider                slider    double  45
              rotateZButton           radiobutton   logical  true
              rotateYButton           radiobutton   logical  false
              rotateXButton           radiobutton   logical  false
           rotateMeshButton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                  numsaddle                  edit     int32  2
                    saddlez       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                      bowlz       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                    zamount                  edit    double  0.1
                   perturbz       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                      zeroz       *    pushbutton      char  '(matlab.ui.control.UIControl)'
               generatetype             popupmenu     int32  1
                geomparam33                  edit    double  0
            geomparam33Text       *          text      char  '(matlab.ui.control.UIControl)'
                geomparam23                  edit    double  4
            geomparam23Text       *          text      char  '(matlab.ui.control.UIControl)'
                geomparam13                  edit    double  4
            geomparam13Text       *          text      char  '(matlab.ui.control.UIControl)'
            geomparam32Text       *          text      char  '(matlab.ui.control.UIControl)'
                geomparam32                  edit    double  0
                geomparam22                  edit    double  0
                geomparam12                  edit    double  2
            geomparam12Text       *          text      char  '(matlab.ui.control.UIControl)'
            geomparam22Text       *          text      char  '(matlab.ui.control.UIControl)'
            geomparam31Text       *          text      char  '(matlab.ui.control.UIControl)'
                geomparam31                  edit    double  4
            geomparam21Text       *          text      char  '(matlab.ui.control.UIControl)'
                geomparam21                  edit    double  0
            geomparam11Text       *          text      char  '(matlab.ui.control.UIControl)'
                geomparam11                  edit    double  2
          replacemeshbutton       *    pushbutton      char  '(matlab.ui.control.UIControl)'
               generatemesh       *    pushbutton      char  '(matlab.ui.control.UIControl)'
             refineproptext                  edit    double  1
           refinepropslider                slider    double  1
                 refinemesh       *    pushbutton      char  '(matlab.ui.control.UIControl)'
                     output       *        Figure      char  '(matlab.ui.Figure)'
         recentprojectsMenu       *          Menu      char  '(matlab.ui.container.Menu)'
        recomputeStagesItem       *          Menu      char  '(matlab.ui.container.Menu)'
             moreStagesItem       *          Menu      char  '(matlab.ui.container.Menu)'
          requestStagesItem       *          Menu      char  '(matlab.ui.container.Menu)'
     importRemoteStagesItem       *          Menu      char  '(matlab.ui.container.Menu)'
   saveExperimentStagesItem       *          Menu      char  '(matlab.ui.container.Menu)'
     deleteUnusedStagesItem       *          Menu      char  '(matlab.ui.container.Menu)'
        deleteAllStagesItem       *          Menu      char  '(matlab.ui.container.Menu)'
   deleteStagesAndTimesItem       *          Menu      char  '(matlab.ui.container.Menu)'
%}
