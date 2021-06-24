create database QlbanH
use QlbanH

create table VatTu
(
	maVT char(5) primary key,
	tenVT varchar(20),
	dvTinh  varchar(10),
	slCon int
)

create table HoaDon
(
	maHD char(5) primary key,
	ngayLap date,
	hoTenKhach varchar(20),
)

create table CTHoaDon
(
	maHD char(5) foreign key references HoaDon on update cascade on delete cascade,
	maVT char(5) foreign key references VatTu on update cascade on delete cascade,
	primary key (maHD, maVT),
	donGiaBan int,
	slBan int
)

insert into VatTu values 
('VT01', 'Vat tu 1', 'Chiec', 100),
('VT02', 'Vat tu 2', 'Cai', 70),
('VT03', 'Vat tu 3', 'Hop', 50)

insert into HoaDon values
('HD01', '1/1/2020', 'Khach 1'),
('HD02', '1/4/2020', 'Khach 2'),
('HD03', '4/4/2020', 'Khach 3')

insert into CTHoaDon values
('HD01', 'VT03', 70000, 20),
'HD02', 'VT02', 90000, 70),
('HD03', 'VT03', 40000, 30),
('HD01', 'VT03', 60000, 20),
('HD03', 'VT02', 100000, 50)

select * from VatTu
select * from HoaDon
select * from CTHoaDon

--CAU 2
	create function Cau2 (@tenVT varchar(20), @ngayBan date)
	returns int
	as
		begin
			declare @tongTien int
			select @tongTien = sum(donGiaBan * slBan)
			from CTHoaDon inner join VatTu on CTHoaDon.maVT = VatTu.maVT
				inner join HoaDon on CTHoaDon.maHD = HoaDon.maHD
			where tenVT = @tenVT and ngayLap = @ngayBan

			return @tongtien
		end

	select dbo.Cau2('Vat tu 3', '4/4/2020') as 'Tong Tien'

--CAU 3
	alter proc Cau3 (@thang int, @nam int)
	as
		begin
			declare @tongVT int
			select @tongVT = sum(slBan)
			from CTHoaDon inner join HoaDon on CTHoaDon.maHD = HoaDon.maHD
			where year(ngayLap) = @nam and MONTH(ngayLap) = @thang

			print concat(N'Tổng số lượng vật tư bán trong tháng ', @thang 
			, ' - ', @nam , ' là: ', @tongVT)
		end

		exec Cau3 1, 2020

--CAU 4
	alter trigger Cau4 on CTHoaDon for delete
	as
		begin
			declare @soDong int, @maHD char(5), @maVT char(5), @slBan int
			select @maHD = maHD, @maVT = maVT, @slBan = slBan from deleted
			set  @soDong =  (select count(*) from CTHoaDon where maHD = @maHD)
			if (@soDong = 2)
				begin
					raiserror ('So dong khong hop le!!!', 16, 1)
					rollback transaction
				end
			else
				update VatTu set slCon = slCon + @slBan where maVT = @maVT
		end

		select * from VatTu
		select * from HoaDon
		select * from CTHoaDon
		--TH1: So dong cua hoa don la 1
		delete from CTHoaDon where maHD = 'HD02' and maVT = 'VT02'
		--TH2: Xoa thanh cong
		delete from CTHoaDon where maHD = 'HD01' and maVT = 'VT03'

		select count(*) from CTHoaDon where maHD = 'HD01'
