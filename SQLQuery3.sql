use qlysinhvien

select * from Khoa
select * from Lop
select * from SinhVien


--TẠO HÀM
	alter function Cau2_2(@tenKhoa varchar(20), @tenLop varchar(20))
	returns @danhSach table (
								maSV char(5), 
								hoTen varchar(20), 
								tuoi int
								)
	as
		begin
			insert into @danhSach
			select maSv, hoTen, 'Tuoi' = DATEDIFF(year, ngaySinh, GETDATE())
			from SinhVien inner join lop on SinhVien.maLop = lop.maLop inner join khoa on lop.maKhoa = khoa.maKhoa
			where tenKhoa = @tenKhoa and tenLop = @tenLop
			return
		end

		select * from dbo.Cau2_2('Khoa 1', 'Lop 3')

--TẠO THỦ TỤC
	alter proc Cau3_3(@tenKhoa varchar(20), @siSo int)
	as
		begin
			declare @maKhoa char(5)

			select @maKhoa = maKhoa
			from khoa
			where tenKhoa = @tenKhoa

			if (not exists (select * from lop where maKhoa = @maKhoa and siSo > @siSo))
				print (N'Không có lơp thỏa man')
			else
				select maLop, tenLop, siSo
				from lop
				where maKhoa = @maKhoa and siSo > @siSo
		end

		select * from Khoa
		select * from Lop
		select * from SinhVien
		--TH1: Số học sinh không thỏa mãn
		exec Cau3_3 'Khoa 2', 10000

		--TH2: Đúng
		exec Cau3_3 'Khoa 2', 2

--TẠO TRIGGER
	create trigger Cau4_4 on SinhVien for delete
	as
		begin
			declare @maSV char(5), @maLop char(5)
			select @maSV = maSv, @maLop = maLop from deleted
			if (not exists (select * from SinhVien where maSv = @maSV))
				begin
					raiserror (N'Không tồn tại sinh viên', 16, 1)
					rollback transaction 
				end
			else
				update Lop set siSo = siSo + 1 where maLop = @maLop
		end

		select * from Khoa
		select * from Lop
		select * from SinhVien
		--TH1: Không có dinh viên
		delete from SinhVien where maSV = 'SV10'
		--TH2: Đúng
		select * from Lop
		select * from SinhVien
		delete from SinhVien where maSV = 'SV01'
		select * from Lop
		select * from SinhVien
