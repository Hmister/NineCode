-- �������ݿ�ṹSQL�ű�
-- Version: 1.1
-- Time: 2018��1��17��
-- Run: SQL Server2012
-- To��SQL 2008R2+
-- By: Jiuone


--�������ݿ⣨���ڲ��ԣ�
--�������
use master
go
if exists(select * from sys.databases where name='NineCode')
	drop database NineCode
go
--�������ݿ�
create database NineCode
go

--�л����ݿ�
use NineCode
go



--�����û���
create table Users
(
--�û����
UNum int primary key identity(10000,1),
--�û�����
UName nvarchar(20) unique not null,
--�û�����//���ܺ�
UPass nvarchar(300) not null,
--��ȫ����
UMail nvarchar(50) null,
--��Ծʱ��
ULogin datetime default(getdate()),
--�˻�״̬
UState nvarchar(5) default('true') check(UState='true' or UState='false'),
)
go

--���������
create table Category
(
--������
CID int primary key identity(100,1),
--��������
CName nvarchar(30) not null
)
go

--������ǩ��
create table Tag
(
--�������
TNum int primary key identity(100,1),
--��������
TName nvarchar(50) not null
)
go

--�������±�
create table Article
(
--���±��
AID int primary key identity(10000,1),
--���±���
ATitle nvarchar(100) not null,
--��������
AText text not null,
--����ʱ��
ATime datetime default(getDate()),
--�����û�
UNum int references Users(UNum),
--��������
CID int references Category(CID)
)
go

--������ϵ��
create table Relation
(
--��ϵ���
RID int primary key identity(10000,1),
--���±��
AID int references Article(AID),
--�������
TNum int references Tag(TNum)
)
go

--�����ļ���
create table Media
(
--�ļ����
MID int primary key identity(10000,1),
--�ļ�����
MName nvarchar(100) not null,
--�ļ���ַ
MUrl nvarchar(200) unique not null,
--�ļ�����
MType nvarchar(10) not null,
--�ϴ�ʱ��
MTime datetime default(getDate()),
--��������
AID int null,
--�����û�
UNum int references Users(UNum)
)
go


--������վ��Ϣ��
create table SiteInfo
(
--ID��ʶ
IID int primary key identity(1,1),
--��վ����
ITitle nvarchar(100) not null ,
--��վ������
ISmall nvarchar(100) not null ,
--��վSEO��Ϣ
ISEO nvarchar(200),
--��վICP������Ϣ
IICP nvarchar(100),
--��վ������������Ϣ
IBei nvarchar(100),
--��վͳ����Ϣ
ICount text,
--��վ�Ƿ�ر�
IIsOff nvarchar(5) default('false') check(IIsOff='true' or IIsOff='false'),
--��վ�ر�ԭ��
IWhyOff nvarchar(500)
)
go



--������վ���ñ�
create table SiteConfig
(
--ID��ʶ
CfgID int primary key identity(1,1),
--SMTP������ַ
CfgServer nvarchar(100),
--SMTP��ַ�˿�
CfgPort int,
--SMTP�˺�
CfgUser nvarchar(100),
--SMTP����
CfgPass nvarchar(100),
--SMTP�����˵�ַ
CfgFrom nvarchar(100)
)
go
 