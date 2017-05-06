fileID = fopen('wider_face_split/wider_face_train_bbx_gt.txt');
fileContent = textscan(fileID,'%s', 'Delimiter', '\n');
fileContent = fileContent{1};

expand = 0.2; ex = expand;
sizexy = [112,96];
minw = 100;
hatHeight = ex;
index = 1;
pictNum = 0 ;
while index <= length(fileContent)
    fileLine = fileContent{index};
    if fileLine(end) == 'g' % this line shows path
        image = imread(['images/',fileLine]);
        index = index +1;
        continue
    end
    if length(fileLine)<5 % this line shows number of picts
        if str2double(fileLine)>5 % more face means inaccurate
            disp(['jump image ', fileContent{index-1}] )
            index = index + str2double(fileLine)+1;
            continue
        end
        for k = 1 : str2double(fileLine)
            index = index + 1; % next line
            pictNum = pictNum+1;
            boxInfo = textscan(fileContent{index},'%d');
            boxInfo=boxInfo{1};
            % change ratio to sizexy
            x = boxInfo(1); y = boxInfo(2); w = boxInfo(3); h = boxInfo(4);
            x = double(x); y = double(y); w = double(w); h = double(h); 
            if w/sizexy(2)<h/sizexy(1)                
                x = x - ( h/sizexy(1)*sizexy(2)-w) / 2;
                w = h/sizexy(1)*sizexy(2);
            end
            if w/sizexy(2)>h/sizexy(1)
                y = y - ( sizexy(1)*w/sizexy(2)-h) / 2;
                h = sizexy(1)*w/sizexy(2);
            end
            %  expand range
            x = x - w*ex; y = y - h*(ex+hatHeight); 
            x1 = x + w*(1+2*ex); y1 = y + h*(1+2*ex+hatHeight);
            if w < minw
                pictNum = pictNum-1;
                continue
            end
            %% Add a flag here: flag =0     
            try
                imgHead = image(y:y1,x:x1, :);
                imgHead = imresize(imgHead,sizexy);
                imwrite(imgHead,['collect/',num2str(pictNum),'.png'],'png',...
                    'Author','Frost','Description' ,'Head image 112*96*8*3, used for AlphaNext', ...
                    'Source' ,'WIDER FACE','Software' ,'MATLAB','Comment',['ID: ', num2str(pictNum)],...
                    'Warning','Produced by Frost, please contact me before use. Xu.Frost@gmail.com');
                disp(['-------------- saving image ',num2str(pictNum)] );
                %% change flag to 1: flag =1
                %% [WARNING] except _flag_, do NOT change anything in this area to avoid the change of output!!
            catch
                pictNum = pictNum-1;
            end
            %% if flag changed:
            %% Add your random expanding code here, then we get four new vars: [y_1,y1_1,x_1:x1_1]
            %% if new vars exceed the initial range, save an empty picture.
            %% if not save new picture
            %% both pictures should replace the original one, the production of Line 51: imwrite....
        end
        index = index +1;
        continue
    end
    msgbox('error')
end

fclose(fileID)
