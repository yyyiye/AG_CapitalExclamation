fileID = fopen('wider_face_split/wider_face_train_bbx_gt.txt');
fileContent = textscan(fileID,'%s', 'Delimiter', '\n');
fileContent = fileContent{1};

expand = 0.2;
ex = expand;
sizexy = [112,96];
minw = 100;
hatHeight = 0.2;
index = 1;
pictNum = 0 ;
Bbox = zeros(5338,4); %bbox信息
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
            boxInfo = boxInfo{1};
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
            rand1 = 0.2-0.4 * rand(1,1);
            rand2 = 0.2-0.4 * rand(1,1);
            x = x - w*(ex + rand1); y = y - h*(ex+hatHeight+rand2); 
            x1 = x + w*(1+2*ex); y1 = y + h*(1+2*ex+hatHeight);
            
            x0 = boxInfo(1) - x; %原始图片中x，y值相对于生成图片的位置
            y0 = boxInfo(2) - y; %原始图片中x，y值相对于生成图片的位置
            x0 = x0 * sizexy(2)/(w*(1+2*ex));
            y0 = y0 * sizexy(1)/(h*(1+2*ex+hatHeight));
            w0 = w * sizexy(2)/(w*(1+2*ex));
            h0 = h * sizexy(1)/(h*(1+2*ex+hatHeight));       
            
%              rand1 = 0.2-0.4 * rand(1,1);
%             rand2 = 0.2-0.4 * rand(1,1);
%             x = x - w*(ex + rand1); y = y - h*(ex+hatHeight+rand2); 
%             x1 = x + w*(1+2*ex+rand1); y1 = y + h*(1+2*ex+hatHeight+rand2);
%             
%             x0 = boxInfo(1) - x; %原始图片中x，y值相对于生成图片的位置
%             y0 = boxInfo(2) - y; %原始图片中x，y值相对于生成图片的位置
%             x0 = x0 * sizexy(2)/(w*(1+2*ex+ rand1));
%             y0 = y0 * sizexy(1)/(h*(1+2*ex+hatHeight+rand2));
%             w0 = w * sizexy(2)/(w*(1+2*ex+rand1));
%             h0 = h * sizexy(1)/(h*(1+2*ex+hatHeight+rand2));       
            if w < minw
                pictNum = pictNum-1;
                continue
            end
            Bbox(pictNum , :) =[x0,y0,w0,h0];
            
            try
                imgHead = image(y:y1,x:x1, :);
                imgHead = imresize(imgHead,sizexy);
                imwrite(imgHead,['collect/',num2str(pictNum),'.png'],'png',...
                    'Author','Frost','Description' ,'Head image 112*96*8*3, used for AlphaNext', ...
                    'Source' ,'WIDER FACE','Software' ,'MATLAB','Comment',['ID: ', num2str(pictNum)],...
                    'Warning','Produced by Frost, please contact me before use. Xu.Frost@gmail.com');
                disp(['-------------- saving image ',num2str(pictNum)] );
            catch
                pictNum = pictNum-1;
            end
            % check file resolution
        end
        index = index +1;
        continue
    end
    msgbox('error')
end
fclose(fileID);

%创建文件
fid = fopen('test.txt','wt');  
%写头部
fprintf(fid,'%s','x  y  w  h');
fprintf(fid,'%c\n',' ');    %换行
%依次写入数据
for k=1:5338; 
    for m = 1:4
        p=num2str(Bbox(k,m));
        fprintf(fid,'%s ',p);    %每个数据用空格隔开
    end
    fprintf(fid,'%c\n',' ');    %写完一行,换行
end
fclose(fid); %关闭文件
