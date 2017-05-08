%% Format
% [id]
% [gender] 0 1 2
% [Hat] 0:NA; 1:black; 2: blue; 3: brown; 4: green; 5: orenge; 6: red; 7:
% gray; 8: white; 9: yellow; 10: clear
% [Glasses] 0:NA; 1:black; 2: blue; 3: brown; 4: green; 5: orenge; 6: red; 7:
% gray; 8: white; 9: yellow;
% [Mask] 0:NA; 1:black; 2: blue; 3: brown; 4: green; 5: orenge; 6: red; 7:
% gray; 8: white; 9: yellow;
% [num] 0,1,2,3
% [path] "collect1/[id].png","collect2/[id].png","collect2/[id].png"
% [bbox] [x,y,w,h],[x,y,w,h],[x,y,w,h]
%% load gender and color
load "data.mat"
%% load bbox
A1 = fscanf(fopen('test1.txt'),'%f',[4 Inf]); A1=round(100*A1')/100;
A2 = fscanf(fopen('test2.txt'),'%f',[4 Inf]); A2=round(100*A2')/100;
A3 = fscanf(fopen('test3.txt'),'%f',[4 Inf]); A3=round(100*A3')/100;
%% start
fid=fopen('result.txt','wt');

for k = 1 : length(No)
    id = No(k);
    %% gender
    gender = Gendercode(k);
    %% color
    % Hat = Hat{k}, there should be number
    Hat = 0;
    % Glasses = Glasses{k}, there should be number
    Glass = 0;
    % Mask = Mask{k}, there should be number
    Mask = 0;
    %% path and boxes
    path = {};boxes={};
    Name = [num2str(No(k)), '.png'];
    if exist(['modified_collect1/',Name], 'file') == 2
        path{end+1} = ['modified_collect1/',Name];        
        boxes{end+1}=A1(id,:);
    end
    if exist(['modified_collect2/',Name], 'file') == 2
        path{end+1}= ['modified_collect2/',Name];
        boxes{end+1}=A2(id,:);
    end
    if exist(['modified_collect3/',Name], 'file') == 2
        path{end+1} = ['modified_collect3/',Name];
        boxes{end+1}=A3(id,:);
    end
    num = length(path);
    if ~isempty(path)
        out = num2str([id, gender, Hat,Glass, Mask,num]);        
        for l=1:num
            out = [out,' "', path{l},'" ',num2str(boxes{l}),' ' ];
        end
        disp(out)
        fprintf(fid,'%s \n',out);
    end
end

fclose(fid);
