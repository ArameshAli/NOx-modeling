% Ali Aramesh
% B832418
% courswork assignment 1: NOx Modelling 

% Generator.PropertyName = NewValue
% Number of points (int: [0,Inf])
% create project
clc;
clear all;
Noxproject = mbcmodel.CreateProject('Noxproject');

% Define Inputs for test plan
  
globalInputs = mbcmodel.modelinput('Symbol',{'L','N','S'},'Name',{'LOAD','SPEED','SPARK'},'Range', {[0 1.5],[800 5500],[-15 15]});

% Create test plan
TP = CreateTestplan( Noxproject, {globalInputs} );

sfDesign = CreateDesign(TP,'Type','Latin Hypercube Sampling','Name','Space filling');
sfDesign = ConstrainedGenerate( sfDesign, 100, 'UnconstrainedSize',...
400, 'MaxIter',3  );

LOAD = sfDesign.Points(:,1);
SPEED = sfDesign.Points(:,2);
SPARK = sfDesign.Points(:,3);

% create an empty data object
data = Noxproject.CreateData;
% geta correctly formatted structure
% TestPlan.varNames={'SPEED','LOAD','SPARK','NOX','STDDEV'};
% TestPlan.data=[Speed(:,2),Load(:,2),Spark(:,2),design_pts(:,5),design_pts(:,6)];
% place data in to the structure 

open('NOx_model.slx');
for i=1:100
    set_param('NOx_model/Load', 'Value','LOAD(i)');
    set_param('NOx_model/Speed', 'Value','SPEED(i)');
    set_param('NOx_model/Spark', 'Value','SPARK(i)');
    sim('NOx_model')
    NOx_emission1(i)=mean(NOx_out);
end

NOx_emission1 = NOx_emission1';
 S=ExportToMBCDataStructure(data);

 S.varNames={'LOAD','SPEED','SPARK','NOx_emission1'};
 S.data = [LOAD(:),SPEED(:), SPARK(:),NOx_emission1(:)];
% Import the structure in to the dat object 
data = BeginEdit(data);
data = ImportFromMBCDataStructure(data, S);
data = CommitEdit(data);
AttachData(TP,data)

% rbf 

RBFModel = mbcmodel.CreateModel('RBF',globalInputs);

Response = CreateResponse(TP,'NOx');
S = DiagnosticStatistics(Response);
emidata = S.Statistics;
PredictedNOx = emidata(:,1);
Residuals = emidata(:,2);
actualNOx = emidata(:,4);
% RMSE

RMSEdata= SummaryStatistics(Response);
PRESS =RMSEdata.Statistics(4);
RMSE = RMSEdata.Statistics(5);
figure(1);
scatter3(Residuals, SPEED,LOAD);
% Question #7
figure(2);
plot(PredictedNOx, actualNOx);
Title('Distribution of residual');
Xlabel('PredictNox');
Ylabel('ResidualNox');
Zlabel('SpeedLoad');

spark = [-15:2:15]';

std(NOx_emission1)
for i=1:100
    set_param('NOx_model/Load', 'value', num2str(LOAD(i)));
    set_param('NOx_model/Speed', 'value', num2str(SPEED(i)));
    for j=1:16
        set_param('NOx_model/Constant', 'value',num2str( LOAD(j)));
    set_param('NOx_model/Spark', 'value',num2str( spark(i)));
        sim('NOx_model')
        NOx_emission1(i)=mean(NOx_out);
    end
end
NOx_emission1=[NOx_emission1]'
for i=1:100
    set_param('NOx_model/Load', 'value', num2str(LOAD(i)));
    set_param('NOx_model/Speed', 'value', num2str(SPEED(i)));
    for j=1:16
        set_param('NOx_model/Constant', 'value',num2str( LOAD(j)));
    set_param('NOx_model/Spark', 'value',num2str( spark(i)));
        sim('NOx_model')
        NOx_emission2(i)=mean(NOx_out);
    end
end

NOx_emission2=[NOx_emission2]'
for i=1:100
    set_param('NOx_model/Load', 'value', num2str(LOAD(i)));
    set_param('NOx_model/Speed', 'value', num2str(SPEED(i)));
    for j=1:16
        set_param('NOx_model/Constant', 'value',num2str( LOAD(j)));
    set_param('NOx_model/Spark', 'value',num2str( spark(i)));
        sim('NOx_model')
        NOx_emission3(i)=mean(NOx_out);
    end
end
NOx_emission3=[NOx_emission3]'



        


