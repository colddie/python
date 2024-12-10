% Loop over patient group to perform single-subject level connectivity nbetwork analysis, 
% make a copy yourself!
%

pad0='/code/work/network/subjects/';
studyn = ["005" "007" "008" "011" "018" "041" "055" "062" "063" "066"];         % normal group
studyp = ["002"];         % patient to look at

% ind1 = []; ind2 = [];
% zscores = zeros(18,18,size(studyp,2));
% sts = zeros(18,size(studyp,2));
    studys1 = [studyn studyp];

    % Assign the label names to LabelID in results_SUV.txt
    labels = cellstr([ "muscle" "kidney_L" "kidney_R" "blood" "spleen" "lung" "liver" "brain" "LV" "pancrea" "spine"]);
    labelid = [];
    for i=1:size(labels,2)
      labelid = [labelid find(strcmp(labels,labels(i)))];  end

    % Construct the normal group
    SUVn=[];
    for istudy = 1:size(studyn,2)
      tmps = dir([pad0 char(studyn(istudy)) '*']);
      pad1 = tmps(1).name;

      filename = [pad0 pad1 '/weightDose.txt'];
      tmp = textread(filename,'%f','delimiter',' '); 
      weight = tmp(1);
      dose = tmp(2) /1e3;
      filename = [pad0 pad1 '/results_SUV.txt'];
      [A B C D E F G H I J] = textread(filename,'%f %f %f %f %f %f %f %f %f %f',...        
      'headerlines',2,...        
      'delimiter',' '); 
      SUVn = [SUVn B/dose*weight];
    end

    % Construct the normal+individual group
    SUVp=[];
    for istudy = 1:size(studys1,2)
      tmps = dir([pad0 char(studys1(istudy)) '*']);
      pad1 = tmps(1).name;
    
      filename = [pad0 pad1 '/weightDose.txt'];
      tmp = textread(filename,'%f','delimiter',' '); 
      weight = tmp(1)       ;
      dose = tmp(2) /1e3     ;
      filename = [pad0 pad1 '/results_SUV.txt'];
      [A B C D E F G H I J] = textread(filename,'%f %f %f %f %f %f %f %f %f %f',...        
      'headerlines',2,...        
      'delimiter',' '); 
      SUVp = [SUVp B/dose*weight];
    end

    % Pearson correaltion for normal group and normal+individual group
    order=[10 8 9 2 7 4 5 1 3 6 11];  % reorder to labelid
    tacs1 = SUVn(order,:);
    tacs2 = SUVp(order,:);
    [N1,E1,d1,st1,cw1,ec1,sp1,pea_cd1]=schemball(tacs1,labels,0.5,0);   pea_cd1(isnan(pea_cd1))=0;
    [N2,E2,d2,st2,cw2,ec2,sp2,pea_cd0]=schemball(tacs2,labels,0.5,0);   pea_cd0(isnan(pea_cd0))=0;

    % Subtract reference network with purtube network
    % tmp = (tacs1(:,size(SUV,2))-mean(tacs2,2)) ./ std(tacs2,0,2);
    tmp = pea_cd1-pea_cd0;

    % Visualize the original individual graph
    figure
    h=schemaball(tmp,cellstr(labels),[1 1 0],[0,1,0]);
    % h=schemaball(tmp,cellstr(labels)); colormap(jet)
    set(h.l(~isnan(h.l)), 'LineWidth',1.4)                         
    set(h.s, 'SizeData',48,'LineWidth',2,'SizeData',100,'MarkerEdgeColor',[1 1 1])  
    set(findobj('type', 'text'), 'color', 'black');
    set(gcf,'color','w');

    % Visualize the Z-score matrix
    % tmp(find(eye(size(tmp,1))))= ind1 *0.2/max(ind1);
    % figure
    % imagesc(tmp,[-0.25,0.25]);
    zscore = tmp ./(1-pea_cd0.*pea_cd0)*(size(studyn,2)-1)
    % zscore_norm = 2 * (zscore - min(zscore(:))) / (max(zscore(:)) - min(zscore(:))) - 1
    h1=schemaball(zscore/5,cellstr(labels),[1 1 0],[0,1,0]);  % command only accept [-1, 1] so narrow the data range
    set(h1.l(~isnan(h1.l)), 'LineWidth',1.4)                         
    set(h1.s, 'SizeData',48,'LineWidth',2,'SizeData',100,'MarkerEdgeColor',[1 1 1])  
    set(findobj('type', 'text'), 'color', 'black');
    set(gcf,'color','w');

    % Compute the network features, thresholding zscore martrix if necessary
    [N,E,d,st,cw,ec,sp]=netPro(abs(zscore),1)  % take the absolute
    p=normcdf(zscore);  
    size(find(p<0.05)) 
 