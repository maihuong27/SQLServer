create database QLBanHang_De7
use QLBanHang_De7

create table Hang
(
	maHang char(5) primary key,
	tenHang varchar(20),
	dvTinh varchar(20),
	slTon int
)

create table HDBan
(
	maHD char(5) primary key,
	ngayBan date,
	hoTenKhach varchar(20)
)

create table HangBan
(
	maHD char(5) foreign key references HDBan on update cascade on delete cascade,
	maHang char(5) foreign key references Hang on update cascade on delete cascade,
	primary key (maHD, maHang),
	donGia money,
	soLuong int
)

insert into Hang values
('H01', 'Hang 1', 'Chiec', 200),
('H02', 'Hang 2', 'Cai', 150)

insert into HDBan values
('HD01', '1/1/2021', 'Khach 1'),
('HD02', '4/4/2019', 'Khach 2')

insert into HangBan values
('HD01', 'H01', 156000, 20),
('HD01', 'H02', 27000, 10),
('HD02', 'H01', 35000, 50),
('HD02', 'H02', 57000, 20)

select * from hang
select * from HDBan
select * from HangBan

/*
Hãy tạo View đưa ra thống kê tiền hàng bán theo từng hóa đơn gồm: 
MaHD,NgayBan,Tổng tiền (tiền=SoLuong*DonGia)
*/
create view Cau2
as
	select HDBan.maHD, ngayBan, 'tongTien' = sum(soLuong * donGia)
	from HangBan inner join HDBan on HangBan.maHD = HDBan.maHD
	group by HDBan.maHD, ngayBan

select * from Cau2

/*
Hãy tạo thủ tục lưu trữ tìm kiếm hàng theo tháng và năm (Với 2 tham số vào là: Thang và Nam). 
Kết quả tìm được sẽ đưa ra một danh sách gồm: MaHang, TenHang, NgayBan, SoLuong, NgayThu. 
Trong đó: Cột NgayThu sẽ là: chủ nhật, thứ hai, ..., thứ bảy (dựa vào giá trị của cột NgayBan)
*/

create proc Cau3 @thang int, @nam int
as
	begin
		select Hang.maHang, tenHang, ngayBan, soLuong, 'ngayThu' = datename(dw, ngayBan)
		from Hang inner join HangBan on Hang.maHang = HangBan.maHang
			 inner join HDBan on HDBan.maHD = HangBan.maHD
		where year(ngayBan) = @nam and MONTH(ngayBan) = @thang
	end

exec Cau3 4, 2019

/*
	Hãy tạo Trigger để tự động giảm số lượng tồn (SLTon) trong bảng Hang, mỗi khi thêm mới 
	dữ liệu cho bảng HangBan. (Đưa ra thông báo lỗi nếu SoLuong>SLTon) 
*/

create trigger Cau4 on HangBan for insert
as
	begin
		declare @maHang char(5), @maHD char(5), @slTon int, @sl int
		select @maHang = maHang, @maHD = maHD, @sl = soLuong from inserted
		select @slTon = slTon from Hang where maHang = @maHang

		if(@sl > @slTon)
			begin
				raiserror ('So luong hang khong du', 16, 1)
				rollback transaction 
			end
		else
			update Hang set slTon = slTon - @sl where maHang = @maHang
	end

insert into Hang values ('H03', 'Hang 3', 'Hop', 300)
--TH1: So luong hang khong du
insert into HangBan values ('HD01', 'H03', 100000, 1000)

--TH2: update
insert into HangBan values ('HD01', 'H03', 100000, 100)

select * from hang
select * from HangBan

									--DE 8

--Đưa ra hóa đơn có tổng tiền vật tư nhiều nhất gồm: MaHD, Tổng tiền
insert into HangBan values ('HD02', 'H03', 105000, 100)
	select maHD, 'tongTien' = sum(donGia*soLuong)
	from HangBan
	group by maHD
	having sum(donGia*soLuong) = (select max(tong)
									 from (select sum(donGia*soLuong) as 'tong'
										from HangBan group by maHD) as tongLuong)


/*
Viết hàm với tham số truyền vào là MaHD, hàm trả về một bảng gồm các thông tin:
MaHD,NgayXuat, MaVT, DonGia, SLBan, NgayThu. Trong đó: Cột NgayThu sẽ là: 
chủ nhật, thứ hai, ..., thứ bảy (dựa vào giá trị của cột NgayXuat)
*/

