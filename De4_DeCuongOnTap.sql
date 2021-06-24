create database QLBenhVien_De4
use QLBenhVien_De4

create table BenhVien
(
	maBV char(5) primary key,
	tenBV varchar(20),
	diaChi varchar(20),
	dienThoai varchar(20)
)

create table KhoaKham
(
	maKhoa char(5) primary key,
	tenKhoa varchar(20),
	soBN int,
	maBV char(5) foreign key references BenhVien on update cascade on delete cascade,
)

create table BenhNhan
(
	maBN char(5) primary key,
	hoTen varchar(20),
	ngaySinh date,
	gioiTinh varchar(20),
	soNgayNV int,
	maKhoa char(5) foreign key references KhoaKham on update cascade on delete cascade
)

insert into BenhVien values 
('BV01', 'Benh vien 1', 'Ha Noi', '12132340834'),
('BV02', 'Benh vien 2', 'TP HCM', '45239759347')

insert into KhoaKham values
('K01', 'Khoa 1', 100, 'BV01'),
('K02', 'Khoa 2', 150, 'BV02')

insert into BenhNhan values
('BN01', 'Benh nhan 1', '1/1/2001', 'Nu', 20, 'K01'),
('BN02', 'Benh nhan 2', '2/2/2002', 'Nam', 1, 'K01'),
('BN03', 'Benh nhan 3', '3/3/2003', 'Nu', 6, 'K02'),
('BN04', 'Benh nhan 4', '4/4/2004', 'Nam', 3, 'K01'),
('BN05', 'Benh nhan 5', '5/5/2005', 'Nu', 10, 'K02')

select * from BenhVien
select * from KhoaKham
select * from BenhNhan

--Tao View thong ke so benh nhan Nu cua tung khoa kham gom: Ma khoa, Ten khoa,soNguoi
create view Cau2
as
	select KhoaKham.maKhoa, tenKhoa, 'soNguoi' = count(*)
	from KhoaKham inner join BenhNhan on KhoaKham.maKhoa = BenhNhan.maKhoa
	where gioiTinh = 'Nu'
	group by KhoaKham.maKhoa, tenKhoa

select * from Cau2

--Ham dua ra tong tien thu duoc cua tung khoa voi tham so la tenKhoa(tien = soNgayNV*60000)
create function Cau3(@tenKhoa varchar(20))
returns money
as
	begin
		declare @tongTien money
		select @tongTien = sum(soNgayNV*60000)
		from KhoaKham inner join BenhNhan on KhoaKham.maKhoa = BenhNhan.maKhoa
		where tenKhoa = @tenKhoa
		return @tongTien
	end

select * from KhoaKham
select * from BenhNhan

select dbo.Cau3('Khoa 1')

/*
Tao trigger them benh nhan trong bang khoa kham, moi khi them moi du lieu cho bang Benh nhan.
Neu so benh nhan trong 1 khoa kham > 50 thi khong cho them va dua ra canh cao
*/

create trigger Cau4 on BenhNhan for insert
as
	begin
		declare @maBN char(5), @maKhoa char(5), @slBN int
		select @maBN = maBN, @maKhoa = maKhoa from inserted
		select @slBN = soBN from KhoaKham where maKhoa = @maKhoa
		if(@slBN > 50)
			begin
				raiserror('So luong benh nhan qua so luong cho phep', 16, 1)
				rollback tran
			end
		else 
			update KhoaKham set soBN = soBN + 1 where maKhoa = @maKhoa
	end

insert into KhoaKham values ('K03', 'Khoa 3', 12, 'BV01')

--TH1: Qua so luong
insert into BenhNhan values ('BN06', 'Benh nhan 6', '1/1/2006', 'Nam', 20, 'K01')
--Th2: Insert thanh cong
insert into BenhNhan values ('BN06', 'Benh nhan 6', '1/1/2006', 'Nam', 20, 'K03')
select * from KhoaKham
select * from BenhNhan
