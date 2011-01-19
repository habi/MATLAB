function cutline = function_CutlineCalculator(Image1,Image2)
    Image1 = double(Image1);
    Image2 = double(Image2);
    [ ImageHeight ImageWidth ] = size(Image1);
    GradientWidth = 2*ImageWidth-1;
    Gradient = zeros( 1,GradientWidth );
    GradientFunction = zeros( 1,GradientWidth );
    Minimum = [ Inf('double') Inf('double') ];
    MinimumPosition = [ 0 0 ];
    w=waitbar(0,'Calculating cutline...');
    for n = 0:ImageWidth-1
       waitbar((n+1)/ImageWidth,w)
       TempValue1 = function_MeanQuadraticDifference(n+1,Image1,Image2);
        TempValue2 = function_MeanQuadraticDifference(n+1,Image2,Image1);
        GradientFunction(n+1) = TempValue1;
        GradientFunction( GradientWidth - n ) = TempValue2;
        if TempValue1 < Minimum(1)
            Minimum(1) = TempValue1;
            MinimumPosition(1) = n+1;
        end
        if TempValue2 < Minimum(2)
            Minimum(2) = TempValue2;
            MinimumPosition(2) = GradientWidth - n;
        end
        if n +1 > 1
            Gradient(n) = ( Gradient(n) + TempValue1 ) * .5;
            Gradient(GradientWidth - n + 1 ) = ( Gradient(GradientWidth - n + 1) - TempValue2 ) * .5;
        end
        if n + 1 < ImageWidth - 1
            Gradient(n+2) = - TempValue1;
            Gradient(GradientWidth - n - 1) = TempValue2;
        end
        if n + 1 == ImageWidth -1
            Gradient(ImageWidth) = ( TempValue2 - TempValue1) * .5;
        end
    end
%     figure
%         subplot(211)
%             plot([1:GradientWidth],Gradient)
%         subplot(212)
%             plot([1:GradientWidth],GradientFunction)
    GradientHeight = [ 0 0 ];
    if MinimumPosition(1) > 1 && Gradient(MinimumPosition(1)-1) < 0 && Gradient(MinimumPosition(1)+1) > 0
        GradientHeight(1) = Gradient(MinimumPosition(1)+1) - Gradient(MinimumPosition(1)-1);
    end
    if MinimumPosition(2) < GradientWidth && Gradient(MinimumPosition(2)-1) < 0 && Gradient(MinimumPosition(2)+1) > 0
        GradientHeight(2) = Gradient(MinimumPosition(2)+1) - Gradient(MinimumPosition(2)-1);
    end
%GradientHeight
    if GradientHeight(2) > GradientHeight(1)
        cutline = MinimumPosition(2) - GradientWidth;
    elseif GradientHeight(1) > GradientHeight(2)
        cutline = MinimumPosition(1);
    elseif Minimum(2) > Minimum(1)
        cutline = MinimumPosition(2) - GradientWidth; 
    else
        cutline = MinimumPosition(1);
    end
    close(w)
end


function MeanQuadraticDifference = function_MeanQuadraticDifference( Overlap, Image1, Image2 )
    [ ImageHeight ,ImageWidth ] = size(Image1);
    DiffImage = Image2(:,1:Overlap) - Image1(:,ImageWidth-Overlap+1:ImageWidth);
    DiffImage = DiffImage .^2;
    MeanQuadraticDifference = sum(sum(DiffImage)) / ( Overlap * ImageHeight );
end