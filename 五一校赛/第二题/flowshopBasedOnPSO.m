clc;clear
%% 载入数据
    data=load('Data1.txt'); %根据所需要的载入数据
    
numOfJobs=size(data,1);%利用size函数读取任务数量
numOfMachines=size(data,2)/2;%利用size函数读取机器数量
TimeOfJobs=zeros(numOfJobs,numOfMachines);
for i = 1:numOfMachines
    TimeOfJobs(:,i) = data(:,2*i);
end

%% 初始化粒子
numOfIterations=3000;%进化次数
numOfIndivisual=200;%个体数目
individual=zeros(numOfIndivisual,numOfJobs);%种群信息

for i=1:numOfIndivisual
    individual(i,:)=randperm(numOfJobs);%使用随机置换函数生成随机序列
end

%% 计算种群适应度
fitOfIndivisual=fitness(individual,TimeOfJobs);%计算种群适应度
[value,index]=min(fitOfIndivisual);%记录最优下标
flowPbest=individual;%当前个体最优
flowGbest=individual(index,:);%当前全局最优
recordPbest=inf*ones(1,numOfIndivisual);%个体最优记录
recordGbest=fitOfIndivisual(index);%群体最优记录
newIndivisual=individual;%创建种群信息的备份，以便更新

%% 循环寻找最优路径
flowLbest=zeros(1,numOfIterations);
for ite=1:numOfIterations
    %计算适应度值
    fitOfIndivisual=fitness(individual,TimeOfJobs);
    
    %更新当前最优和历史最优
    for i=1:numOfIndivisual
        if fitOfIndivisual(i)<recordPbest(i) %若当前值优于历史个体最优
            recordPbest(i)=fitOfIndivisual(i);%则更新
            flowPbest(i,:)=individual(i,:);
        end
        if fitOfIndivisual(i)<recordGbest %若当前值优于历史全体最优
            recordGbest=fitOfIndivisual(i);%则更新
            flowGbest=individual(i,:);
        end
    end
    
    [~,index]=min(recordPbest);%记录个体最优中的最优下标
    recordGbest(ite)=recordPbest(index);%记录种群中最优个体
    
    
    for i=1:numOfIndivisual
       %% 与个体最优进行交叉
        c1=unidrnd(numOfJobs-1);%产生交叉位
        c2=unidrnd(numOfJobs-1);%产生交叉位
        while c1==c2
            c1=round(rand*(numOfJobs-2))+1;
            c2=round(rand*(numOfJobs-2))+1;
        end
        chb1=min(c1,c2);
        chb2=max(c1,c2);
        cros=flowPbest(i,chb1:chb2);
        ncros=size(cros,2);      
        %删除与交叉区域相同元素
        for j=1:ncros
            for k=1:numOfJobs
                if newIndivisual(i,k)==cros(j)%若交叉区域存在
                    newIndivisual(i,k)=0;%则置零
                    for t=1:numOfJobs-k %交换newIndivisual(i,k+t-1)和newIndivisual(i,k+t)
                        temp=newIndivisual(i,k+t-1);
                        newIndivisual(i,k+t-1)=newIndivisual(i,k+t);
                        newIndivisual(i,k+t)=temp;
                    end
                end
            end
        end
        %插入交叉区域
        newIndivisual(i,numOfJobs-ncros+1:numOfJobs)=cros;
        %新的makespan更小则更新
        curMakespan=makespan(newIndivisual(i,:),TimeOfJobs);
        if fitOfIndivisual(i)>curMakespan
            individual(i,:)=newIndivisual(i,:);
        end
        
       %% 与全体最优进行交叉
        c1=round(rand*(numOfJobs-2))+1;  %产生交叉位
        c2=round(rand*(numOfJobs-2))+1;  %产生交叉位
        while c1==c2
            c1=round(rand*(numOfJobs-2))+1;
            c2=round(rand*(numOfJobs-2))+1;
        end
        chb1=min(c1,c2);
        chb2=max(c1,c2);
        cros=flowGbest(chb1:chb2); 
        ncros=size(cros,2);      
        %删除与交叉区域相同元素
        for j=1:ncros
            for k=1:numOfJobs
                if newIndivisual(i,k)==cros(j)%若交叉区域存在
                    newIndivisual(i,k)=0;%则置零
                    for t=1:numOfJobs-k %交换newIndivisual(i,k+t-1)和newIndivisual(i,k+t)
                        temp=newIndivisual(i,k+t-1);
                        newIndivisual(i,k+t-1)=newIndivisual(i,k+t);
                        newIndivisual(i,k+t)=temp;
                    end
                end
            end
        end
        %插入交叉区域
        newIndivisual(i,numOfJobs-ncros+1:numOfJobs)=cros;
        %新的makespan更小则更新
        curMakespan=makespan(newIndivisual(i,:),TimeOfJobs);
        if fitOfIndivisual(i)>curMakespan
            individual(i,:)=newIndivisual(i,:);
        end
        
       %% 变异操作
        c1=round(rand*(numOfJobs-1))+1;   %产生变异位
        c2=round(rand*(numOfJobs-1))+1;   %产生变异位
        while c1==c2
            c1=round(rand*(numOfJobs-2))+1;
            c2=round(rand*(numOfJobs-2))+1;
        end
        temp=newIndivisual(i,c1);
        newIndivisual(i,c1)=newIndivisual(i,c2);
        newIndivisual(i,c2)=temp;
        
        %新的makespan更小则更新
        curMakespan=makespan(newIndivisual(i,:),TimeOfJobs);
        if fitOfIndivisual(i)>curMakespan
            individual(i,:)=newIndivisual(i,:);
        end
    end

    [value,index]=min(fitOfIndivisual);%记录最优的适应值及其下标
    flowLbest(ite)=fitOfIndivisual(index);%记录迭代次数时的适应值
    flowGbest=individual(index,:);%记录当前最优解
end

%% 显示最优解
fprintf('The optimal makespan is: %d\n',min(flowLbest));
fprintf('The order is: \n');
for i=1:numOfJobs
    fprintf('%3d\n',flowGbest(i));
end
fprintf('\n');

%% 绘制迭代图
%% figure,
%% plot(flowLbest),
%% title('流水车间调度的训练过程图','FontSize',17),%图标题
%% xlabel('迭代次数'),%横轴名称
%% ylabel('适应度值'),%纵轴名称
%% grid on;%开启网格线

%% 绘制甘特图
 gantt(flowGbest,TimeOfJobs);
