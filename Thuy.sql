create database QLBH_Thuy
use QLBH_Thuy

create table Hang
(
	maHang char(5) primary key,
	tenHang varchar(20),
	soLuong int,
	giaBan money
)

create table MuaHang
(
	STT int identity(1, 1) primary key,
	maHang char(5) foreign key references Hang on update cascade on delete cascade,
	nguoiBan varchar(20),
	soLuongBan int,
	ngayBan date
)

insert into Hang values 
('H01', 'Hang 1', 100, 20000),
('H02', 'Hang 2', 60, 100000),
('H03', 'Hang 3', 80, 250000),
('H04', 'Hang 4', 70, 160000),
('H05', 'Hang 5', 20, 470000)

insert into MuaHang values
('H01', 'Nguoi ban 1', 20, '1/1/2021'),
('H01', 'Nguoi ban 2', 10, '4/4/2021'),
('H02', 'Nguoi ban 3', 40, '8/8/2021'),
('H02', 'Nguoi ban 4', 10, '10/10/2021'),
('H03', 'Nguoi ban 5', 70, '12/12/2021'),
('H04', 'Nguoi ban 6', 80, '7/7/2021'),
('H05', 'Nguoi ban 7', 10, '6/26/2021')

select * from Hang
select * from MuaHang

--Hàm trả về tổng doanh thu từ ngày x đến ngày y, với mã hàng, x, y được nhập từ BP
create function Cau2(@x int, @y int, @maHang char(5))
returns money
as
	begin
		declare @tongTien int
		select @tongTien = sum(soLuongBan * giaBan)
		from Hang inner join MuaHang on Hang.maHang = MuaHang.maHang
		where (day(ngayBan) between @x and @y) and Hang.maHang = @maHang
		return @tongTien
	end

select dbo.Cau2(1, 10, 'H01')

--Hàm trả về thông tin mã hàng, tên hàng, giá bán, số lượng bán, thành tiền = số lượng bán * giá bán của hàng có mã hàng nhập từ BP
create function Cau3(@maHang char(5))
returns @thongTin table (
							maHang char(5),
							tenHang varchar(20),
							giaBan money,
							soLuongBan int,
							thanhTien money
							)
as
	begin
		declare @soLuongBan int
		select @soLuongBan = sum(soLuongBan) from MuaHang where maHang = @maHang

		insert into @thongTin
		select Hang.maHang, tenHang, giaBan, 'soLuongBan' = @soLuongBan, 'thanhTien' = giaBan*@soLuongBan
		from Hang
		where Hang.maHang = @maHang
		return
	end

select * from dbo.Cau3('H02')

--Tạo trigger cập nhật số lượng mua hàng của bảng mua hàng. Nếu cập nhật > 1 bản ghi thì báo lỗi. Ngược lại kiểm tra đã tồn tại mã hàng này hay chưa.
--Nếu không tồn tại báo lỗi. Ngược lại cập nhật
create trigger Cau4 on MuaHang for update
as
	begin
		if(@@ROWCOUNT > 1)
			begin
				raiserror(N'Không cập nhập nhiều hơn 1 bản ghi', 16, 1)
				rollback transaction 
			end
		else
			begin
			declare @maHang char(5)
			select @maHang = maHang from deleted

				if (not exists(select * from Hang where maHang = @maHang))
					begin
						raiserror(N'Mã hàng không tồn tại', 16, 1)
						rollback transaction
					end
			end
	end

	select * from MuaHang
	--TH1: Cập nhật nhiều hơn 1 bản ghi
	update MuaHang set soLuongBan = 10000 where maHang = 'H01'
	--TH2: Mã hàng không tồn tại
	update MuaHang set soLuongBan = 1000 where maHang = 'H100'
	--TH3: Cập nhật thành công
	update MuaHang set soLuongBan = 1000 where maHang = 'H05'
	select * from MuaHang

--Tạo trigger tặng thêm cho 5 hóa đơn mua hàng đầu tiên mỗi hóa đơn thêm 1 sản phẩm tức là số lượng bán tăng lên 1 
-- => Câu này dùng con trỏ, mình không thi