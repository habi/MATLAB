function [AbsError, AverageError] = fct_ModelCalculation(Sinogram,DetectorWidth,Overlap,ProtocolNumProj,PaddedPhantom,varargin)
    disp('---');
    SubScanStartPosition = 1;
    SubScanStepWidth = DetectorWidth-Overlap;
    SinogramHeight =  size(Sinogram,2);
    ResultSinogram = [];
    FigureNr =0;
    if nargin > 5
        FigureNr = varargin{1};
    end
    ResultSinogram = zeros([size(Sinogram)]);
    for SubScan=1:length(ProtocolNumProj)
        disp(['interpolating SubScan ' num2str(SubScan) ]);
%         startpos=SubScanStartPosition
%         endpos=SubScanStartPosition+DetectorWidth-1
        SubBlock = fct_InterpolateImageRows(Sinogram(SubScanStartPosition:SubScanStartPosition+DetectorWidth-1,:), ...
            round(SinogramHeight/ProtocolNumProj(SubScan)),1); % 1 > transponiert Bild
%         SubBlockSize= size(SubBlock);
        ResultSinogram(SubScanStartPosition:SubScanStartPosition+DetectorWidth-1,:) = SubBlock;
        SubScanStartPosition = SubScanStartPosition + SubScanStepWidth;
    end
    
    %% iradon
    disp('reconstructing the - possibly interpolated - sinogram')
    ResultReconstruction = iradon(ResultSinogram,[0:179/(SinogramHeight-1):179],...
        'linear','Ram-lak',1,SinogramHeight);
    DifferenceImage = PaddedPhantom-ResultReconstruction;
    AbsError = sum(sum(DifferenceImage .^2));
    AverageError = AbsError / (SinogramHeight ^2);

    %% disp
    if FigureNr > 0 
        %figure(FigureNr)
        figure
            subplot(221)
                imshow(Sinogram',[])
                axis on
                colorbar
                title('Transposed Original Sinogram')
            subplot(222)
                imshow(PaddedPhantom,[])
                axis on
                colorbar
                title('Original Phantom')               
            subplot(223)
                imshow(ResultSinogram',[])
                axis on
                colorbar
                title('Transposed Resulting Sinogram')
            subplot(224)
                imshow(ResultReconstruction,[])
                axis on
                colorbar          
                title('Resulting Reconstruction')
    end
end
