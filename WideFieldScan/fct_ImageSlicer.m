function SubScans=fct_ImageSlicer(InputImage,AmountOfSubScans,DetectorWidth,Overlap_px,showImg)
    wb = waitbar(0,'Please wait...');
    ImageHeight = size(InputImage,1);
    ImageWidth = size(InputImage,2);
    EnlargedImage = [ InputImage zeros(ImageHeight,2*Overlap_px)];
    ConcatenatedImage = [];
    EndWidth=Overlap_px+1;
    for n=1:AmountOfSubScans
        waitbar(n/AmountOfSubScans)
        StartWidth = EndWidth - ( Overlap_px / 2 );
        EndWidth = StartWidth + DetectorWidth;
        SubScans(n).Image= EnlargedImage(:,StartWidth:EndWidth);
        ConcatenatedImage = [ConcatenatedImage SubScans(n).Image];
        pause(1)
        %disp(['SubScan ' num2str(n) ': StartWidth =' num2str(StartWidth) ', EndWidth =' num2str(EndWidth) ]);
    end
    close(wb)          
    if showImg == 1
        figure(1);
            subplot(221)
                imshow(InputImage,[]);
                title('phantom')
                axis on tight
            subplot(222)
                imshow(EnlargedImage,[]);
                title('Enlarged Image')
                axis on tight
            subplot(2,2,[3 4])
                imshow(ConcatenatedImage,[])
                title([num2str(AmountOfSubScans) ' Subscans: sliced and diced'])           
                axis on tight
    end
end