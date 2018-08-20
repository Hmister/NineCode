
-- �������ݱ�洢����SQL�ű�
-- Version: 1.1
-- Time: 2018��1��17��
-- Run: SQL Server2012
-- To��SQL 2008R2+
-- By: Jiuone

  
--�л����ݿ�
use NineCode
go


--�˻������Ϣͳ��
--����:UNum
--���:ͳ����Ϣ����
create proc GetCount
(
@num int
)
as
select
(select COUNT(AID) from Article where UNum=@num)as ACount,
(select COUNT(MID) from Media where UNum=@num) as MCount,
(select ULogin from Users where UNum=@num) as ULogin  
go

--ִ�в���
--exec GetCount 10000
go


---------------------------------------------
--�ʺ�ʹ����ز���
---------------------------------------------

--�˻���¼��֤
--����:�û�������
--���:��ȷ:�û�ID ����:false
create proc CheckLogin
(
@name nvarchar(20),
@pass nvarchar(300)
)
as
declare @res nvarchar(50)
select @res=UState from Users where UName=@name
if(@res='false')
begin
	select 'State'
	return
end
select 
	@res=UPass COLLATE Chinese_PRC_CS_AI
from 
	Users 
where 
	UName COLLATE Chinese_PRC_CS_AI =@name 
if(@res COLLATE Chinese_PRC_CS_AI=@pass COLLATE Chinese_PRC_CS_AI)
begin
	select UNum from Users where UName=@name
	update Users set ULogin=getdate() where UName=@name
end
else
	select 'false'
go
--ִ�в���
--exec CheckLogin 'user','123456'
go


create proc GetMailByName
(
@name nvarchar(20)
)
as
declare @res int
select @res=COUNT(UMail) from Users where UName=@name
if(@res=0)
	select 'false'
else
begin
	select UMail from Users where UName=@name
end
go

--ִ�в���
--exec GetMailByName 'admin'
go



---------------------------------------------
--��Ա������ز���
---------------------------------------------
--��ȡ��վ������ͨ����Ա��Ϣ
--���룺��
--�������վ����Ա��Ϣ�б�
create proc GetUserList
as
select
	UNum,
	UName,
	UMail,
	ULogin,
	UState,
	(select 
		count(AID) 
	 from 
		Article a 
	 where 
		a.UNum=u.UNum 
	)as ACount
from 
	Users u 
where 
	UNum!=10000
go

--ִ�в���
--exec GetUserList
go


--������ͨ����Ա�˻�
--���룺S/D/R����ָ��û�UNum�����ܺ�Ĭ��������
--�����true��false
create proc MgrAdmin
(
@type nvarchar(2),
@num int,
@newpass nvarchar(300)=''
)
as
begin transaction
if(@type='S')
begin
	update Users set UState='true' where UNum=@num
end
else if(@type='D')
begin
	update Users set UState='false' where UNum=@num
end
else if(@type='R')
begin
	update Users set UState='true',UMail=null,UPass=@newpass where UNum=@num
end
else
begin
	select 'false'
	return
end
if(@@ERROR=0)
begin
	commit transaction
	select 'true'
end
else
begin
	rollback transaction
	select 'false'
end
go

--ִ�в���
--exec MgrAdmin 'S',10001
go

--�����վ����Ա
--���룺
--�����
create proc AddAdminUser
(
@name nvarchar(20),
@pass nvarchar(300),
@mail nvarchar(50)=null
)
as
begin transaction
declare @res nvarchar(20)='N'
select @res=UName from Users where UName=@name
if(@res='N')
begin
insert into Users values(@name,@pass,@mail,default,default)
if(@@ERROR=0)
begin
	commit transaction 
	select 'true'
end
else
begin
	rollback transaction
	select 'false'
end
end
else
select 'UName'
go

--ִ�в���
--exec AddAdminUser 'test2','123456',''
go


---------------------------------------------
--����������ز���
---------------------------------------------
--��ȡָ���û���Ϣ
--���룺��
--�������վ����Ա��Ϣ�б�
create proc GetUserInfoById
(
@unum int
)
as
select
	UNum,
	UName,
	UMail,
	ULogin,
	UState,
	(select 
		count(AID) 
	 from 
		Article a 
	 where 
		a.UNum=u.UNum 
	)as ACount
from 
	Users u 
where 
	UNum=@unum
go

--ִ�в���
--exec GetUserInfoById 10000
go




---------------------------------------------
--վ����Ϣ��ز���
---------------------------------------------

--����վ�������Ϣ
--���룺վ����ϢID Ĭ��Ϊ1
--�����վ�������Ϣ
create proc LoadSiteInfo
(
@id int=1 --Ĭ��ֵ
)
as
select * from SiteInfo where IID=@id
go

--ִ�в���
--exec LoadSiteInfo
go



---------------------------------------------
--���¹�����ز���
---------------------------------------------

--�½����¼���
--���� ������ID UNum
--��� ������ID
create proc NewArticel
(
@id nvarchar(20)
)
as
begin transaction
insert into Article values('Null_Title','NineCode',default,@id,100)
if(@@ERROR=0)
begin
	commit transaction
	select top 1 @id=AID from Article order by ATime desc
	select @id
end
else
begin
	rollback transaction
	select 'false'
end
go

--ִ�в���
--exec NewArticel 10000
go


--�������������
--����: ��
--���: true/false �ַ���
create proc ClearNullArticle
as
begin transaction
delete from Article where ATitle='Null_Title'
if(@@ERROR=0)
begin
	commit transaction 
	select 'true'
end
else
begin
	rollback transaction
	select 'false'
end
go

--ִ�в���
--exec ClearNullArticle
go


--��������
--��������±��,���±���,��������,�����û�,��������
--�����true/false�ַ���
create proc UpArticle
(
--���±��
@AID int ,
--���±���
@ATitle nvarchar(100) ,
--��������
@AText text ,
--��������
@CID int,
--�����û�
@UNum int
)
as
begin transaction 
update 
	Article 
set 
	ATitle=@ATitle,
	AText=@AText,
	ATime=GETDATE(),
	UNum=@UNum,
	CID=@CID 
where 
	AID=@AID
if(@@ERROR=0)
begin
	commit transaction 
	select 'true'
end
else
begin
	rollback transaction
	select 'false'
end
go

--ִ�в���
--exec UpArticle 10000,'���²���','���µ�����',101,10000
go


--ɾ������
--���룺����ID
--�����true/false�ַ���
create proc DelArticle
(
@id int
)
as
begin transaction
--���¸�����Ϣ
update Media set AID=0 where AID=@id
--ɾ����ǩ��ϵ
delete from Relation where AID=@id
--ɾ������
delete from Article where AID=@id
if(@@ERROR=0)
begin
	commit transaction
	select 'true'
end
else
begin
	rollback transaction
	select 'false'
end
go

--ִ�в���
--exec DelArticle 10009
go


--��ȡ�����б�
--���룺����ID Ĭ�� ��ѯ����
--�����ָ������������б�
create proc GetArticleByCID
(
@cid nvarchar(50)=''
)
as
if(@cid!='')
	set @cid='and c.CID='+@cid
declare @sql nvarchar(max)
set @sql=
'select 
	a.AID,
	a.ATitle,
	u.UName,
	c.CName,
	CONVERT(nvarchar(111),ATime,23)as ATime
from 
	Article a, 
	Users u,
	Category c 
where 
	a.UNum=u.UNum 
	and a.CID=c.CID '
set @sql=@sql+@cid
exec (@sql)
go

--ִ�в���
--exec GetArticleByCID ''
--exec GetArticleByCID '101'
go



---------------------------------------------
--����������ز���
---------------------------------------------

--��Ӹ���
--���룺��������������ַ���������ͣ�������ID������ID(Ĭ��0)
--�����true/false �ַ���
create proc AddFile
(
@name nvarchar(100),
@url nvarchar(200),
@type nvarchar(10),
@unum int,
@aid int=0
)
as
begin transaction
declare @res int
insert into Media values(@name,@url,@type,default,@aid,@unum) 
if(@@ERROR=0)
begin
	commit transaction
	select 'true'
end
else
begin
	rollback transaction
	select 'false'
end
go

--ִ�в���
--exec AddFile 'test4.png','/UpLoad/2018/2/20180202155326.jpg','image',10000,10005
go


--ɾ������
--���룺����ID
--�����true/false �ַ���
create proc DelMediaFile
(
@mid int
)
as
begin transaction
delete from Media where MID=@mid
if(@@ERROR=0)
begin
	commit transaction
	select 'true'
end
else
begin
	rollback transaction
	select 'false'
end
go

--ִ�в���
--exec DelMediaFile 10000
go

--��ȡ����URL
--���룺����ID
--���������URL
create proc GetUrlById
(
@mid int
)
as
select 
	MUrl 
from 
	Media 
where 
	MID=@mid
go

--ִ�в���
--exec GetUrlById 10000


--��ȡý����б�
--���룺�ļ�����/�����ļ����⡢��ѯ����T/K
--�����ý��������б�����ʱ�俿ǰ���ų������¹����ģ�
create proc GetMediaList
(
@by nvarchar(2)='T',
@key nvarchar(200)='0'
)
as
if(@by='T'and @key='0')
begin
select
	m.MID,
	m.MName,
	m.MTime,
	m.MType,
	m.MUrl,
	u.UName
from 
	Media m,
	Users u 
where 
	m.UNum=u.UNum 
	and AID=0  
order by
	MTime desc
end
else if(@by='T'and @key!='0')
begin
select
	m.MID,
	m.MName,
	m.MTime,
	m.MType,
	m.MUrl,
	u.UName
from 
	Media m,
	Users u 
where 
	m.UNum=u.UNum 
	and AID=0  
	and MType=@key
order by
	MTime desc
end
else if(@by='K'and @key!='0')
begin
select
	m.MID,
	m.MName,
	m.MTime,
	m.MType,
	m.MUrl,
	u.UName
from 
	Media m,
	Users u 
where 
	m.UNum=u.UNum 
	and AID=0 
	and MName like '%'+@key+'%'
order by
	MTime desc
end
go

--ִ�в���
--exec GetMediaList 
--exec GetMediaList 'T','ZIP'
--exec GetMediaList 'K','2'
go

--��ȡ�����ļ������б�
--���룺��
--����������ļ������б�
create proc GetMediaType
as
select 
	MType
from 
	Media
group by 
	MType 
order by 
	MType asc 
go

--ִ�в���
--exec GetMediaType


--��ȡ����ͼƬ
--���룺����ID/�������±��⡢��ѯ����N/T
--��������������б�����ʱ�俿ǰ��
create proc GetArticileImg
(
@by nvarchar(2)='D',
@key nvarchar(200)='0'
)
as
if(@by='D')
	select
		m.MID,
		m.MName,
		m.MUrl
	from
		Media  m,
		Article a
	where 
		m.AID=a.AID
		and m.AID!=0
	order by m.MTime desc
else if(@by='N')
	select
		m.MID,
		m.MName,
		m.MUrl
	from
		Media  m,
		Article a
	where 
		m.AID=a.AID 
		and m.AID!=0
		and a.AID=@key
	order by m.MTime desc
else if(@by='T')
	select
		m.MID,
		m.MName,
		m.MUrl
	from
		Media  m,
		Article a
	where 
		m.AID=a.AID
		and m.AID!=0
		and a.ATitle like '%'+@key+'%'
	order by m.MTime desc
go

--ִ�в���
--exec GetArticileImg 'N','100001'
go


--ɾ������ͼƬ
--���룺��������
--�����true/false �ַ���
create proc DelArticleImage
(
@url nvarchar(200)=''
)
as
begin transaction
delete from Media where MUrl=@url
if(@@ERROR=0)
begin
	commit transaction
	select 'true'
end
else
begin
	rollback transaction
	select 'false'
end
go

--ִ�в���
--exec DelArticleImage
go



---------------------------------------------
--��ǩ������ز���
---------------------------------------------

--������±�ǩ
--���룺����ID
--�����true/false�ַ���
create proc ClearTag
(
@id int
)
as
begin transaction
delete from Relation where AID=@id
if(@@ERROR=0)
begin
	commit transaction
	select 'true'
end
else
begin
	rollback transaction
	select 'false'
end
go

--ִ�в���
--exec ClearTag 10005
go


--��ӱ�ǩ����ϵ,û��������
--���룺������������id
--�����true/false�ַ���
create proc AddTag
(
@tag nvarchar(50),
@aid int
)
as
begin transaction
declare @num int 
set @num=0
select @num=TNum from Tag where TName=@tag
if(@num=0)
begin
	insert into Tag values(@tag)
	select @num=TNum from Tag where TName=@tag
end
insert into Relation values(@aid,@num)
if(@@ERROR=0)
begin
	commit transaction
	select 'true'
end
else
begin
	rollback transaction
	select 'false'
end
go

--ִ�в���
--exec AddTag '���Ա�ǩ',10000
go


--��ȡָ�����±�ǩ
--���룺����ID
--��������±�ǩ�б�
create proc GetTagById
(
@aid int
)
as
select 
	t.TName 
from 
	Relation r,
	Tag t 
where 
	r.TNum=t.TNum 
	and r.AID=@aid
go

--ִ�в���
--exec GetTagById 10006
go


--��ǩ�����ɾ��
--���룺��������(D/U)����ǩID���µı�ǩ�� Ĭ��Ϊ��
--�����true/false�ַ���
create proc MgrTag
(
@type char,
@id int=0,
@name nvarchar(100)=''
)
as
begin transaction
if(@type='D')
begin
	delete from Relation where TNum=@id 
	delete from Tag where TNum=@id 
end
else if(@type='U')
	update Tag set TName=@name where TNum=@id
if(@@ERROR=0)
begin
	commit transaction
	select 'true'
end
else
begin
	rollback transaction
	select 'false'
end
go

--ִ�в���
--exec MgrTag 'D',110
--exec MgrTag 'U',109,'���Ա�ǩ'
go


--��ȡ��ǩ�б�����
--���룺��
--������������±�ǩ��Ϣ
create proc GetTagList
as
select 
	TNum,
	TName,
	(
	select
		 count(AID)
	from 
		Relation r 
	where 
		t.TNum=r.TNum
	)
	as
	ACount
 from 
	Tag t
go

--ִ�в���
--exec GetTagList
go



---------------------------------------------
--���ݷ��������ز���
---------------------------------------------

--��ȡ�����б�
--���룺��
--��������ݷ����б�
create proc GetCategory
as
select * from Category order by CID asc
go

--ִ�в���
--exec GetCategory
go


--����������ɾ��
--���룺��������(I/D/U)������ID���µķ����� Ĭ��Ϊ��
--�����true/false�ַ���
create proc MgrCategory
(
@type char,
@id int=0,
@name nvarchar(100)=''
)
as
begin transaction
if(@type='I')
	insert into Category values(@name)
else if(@type='D')
	delete from Category where CID=@id 
else if(@type='U')
	update Category set CName=@name where CID=@id
if(@@ERROR=0)
begin
	commit transaction
	select 'true'
end
else
begin
	rollback transaction
	select 'false'
end
go

--ִ�в���
--exec MgrCategory 'I',default,'SQL����'
--exec MgrCategory 'D',105
--exec MgrCategory 'U',106,'SQL����'
go


--��ȡ�����б�����
--���룺��
--�������վ������Ϣ
create proc GetCategoryList
as
select 
	CID,
	CName,
	(
		select
			 count(AID)
		from 
			Article a 
		where 
			a.CID=c.CID
	)
	as
	ACount
 from 
	Category c
go

--ִ�в���
--exec GetCategoryList
go



---------------------------------------------
--ǰ̨��Ϣ��ȡ��ز���
---------------------------------------------
	
--���������
--���룺�ؼ���
--��������������
create proc SearchArticle
(
@key nvarchar(100)
)
as
select 
	a.AID,
	a.ATitle,
	a.AText,
	a.ATime,
	u.UName,
	c.CName
from
	Article a,
	Users u,
	Category c	
where
	a.ATitle like '%'+@key+'%' 
	or a.AText like '%'+@key+'%'
	and a.UNum=u.UNum
	and a.CID=c.CID
go

--ִ�в���
--exec SearchArticle '����'
go


--��ȡָ��������ϸ��Ϣ
--���룺����ID
--�����������ϸ��Ϣ
create proc GetArticleById
(
@id int
)
as
select 
	a.AID,
	a.ATitle,
	a.AText,
	a.ATime,
	u.UName,
	c.CName
from 
	Article a,
	Users u,
	Category c
where 
	a.AID=@id
	and a.UNum=u.UNum
	and a.CID=c.CID
go

--ִ�в���
--exec GetArticleById 10001
go


--��ȡ�����ھ�ҳID
--���룺��ǰҳ����ID
--�����Prev ��һҳ����ID Next ��һҳ����ID
create proc GetBrother
(
@id int
)
as
declare @prev int,@next int 
set @next=0
set @prev=0
select top 1 @prev=AID from Article where AID<@id order by AID desc
select top 1 @next=AID from Article where AID>@id order by AID asc
if(@prev=0)
	select @prev=max(AID) from Article
if(@next=0)
	select @next=min(AID) from Article
select @prev  as Prev ,@next as Next
go

--ִ�в���
--exec GetBrother 10000
go
