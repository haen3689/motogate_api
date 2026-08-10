# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
AdminUser.find_or_create_by!(email: 'admin@example.com') do |admin|
  admin.password = 'password'
  admin.password_confirmation = 'password'
  admin.role = 'admin'
end

[
  { position: 0, title: "ທະບຽນລົດງ່າຍ",   subtitle: "ຈັດການເອກະສານລົດຂອງທ່ານ\nໄດ້ຄົບໃນທີ່ດຽວ" },
  { position: 1, title: "ບໍລິການຄົບຄ້ວາ", subtitle: "ກວດກາເຕັກນິກ ຈ່າຍຄ່າທາງ\nແລະ ປະກັນໄພ ສະດວກໄວ" },
  { position: 2, title: "ແຈ້ງເຕືອນທັນທີ", subtitle: "ຕິດຕາມສະຖານະ ແລະ ຮັບການ\nແຈ້ງເຕືອນທຸກຄັ້ງໂດຍທັນທີ" },
].each do |attrs|
  OnboardingSlide.find_or_create_by!(position: attrs[:position]) do |s|
    s.title    = attrs[:title]
    s.active   = true
  end
end

# ── Inspection Centers ────────────────────────────────────────────────────
[
  { name: 'ສູນກວດກາເຕັກນິກ ວຽງຈັນ (ຫຼັກ 20)', location: 'ບ້ານດົງໂພສີ, ເມືອງຫາດຊາຍຟອງ, ນະຄອນຫຼວງວຽງຈັນ', phone: '021 812345', status: 'active', capacity_per_day: 100 },
  { name: 'ສູນກວດກາເຕັກນິກ ຫຼວງພະບາງ',          location: 'ເມືອງຫຼວງພະບາງ, ແຂວງຫຼວງພະບາງ',                 phone: '071 212345', status: 'active', capacity_per_day: 50  },
  { name: 'ສູນກວດກາເຕັກນິກ ສະຫວັນນະເຂດ',        location: 'ເມືອງໄກສອນ ພົມວິຫານ, ແຂວງສະຫວັນນະເຂດ',         phone: '041 212345', status: 'active', capacity_per_day: 80  },
  { name: 'ສູນກວດກາເຕັກນິກ ຈຳປາສັກ',            location: 'ເມືອງປາກເຊ, ແຂວງຈຳປາສັກ',                       phone: '031 212345', status: 'active', capacity_per_day: 60  },
].each do |attrs|
  center = InspectionCenter.find_or_create_by!(name: attrs[:name]) { |c| c.assign_attributes(attrs) }
  next if center.inspection_services.exists?
  [
    { name: 'ກວດກາລົດຈັກທົ່ວໄປ',    vehicle_type: 'motorcycle', min_cc: 0,    max_cc: 200,   price: 50_000,  detail: 'ກວດກາລະບົບເບກ, ໄຟ, ແລະ ສະພາບທົ່ວໄປ', status: 'active' },
    { name: 'ກວດກາລົດເກັງ / SUV',    vehicle_type: 'car',        min_cc: 1000, max_cc: 3000,  price: 150_000, detail: 'ກວດກາຈັກ, ຊ່ວງລ່າງ, ແລະ ອາຍພິດ',       status: 'active' },
    { name: 'ກວດກາລົດບັນທຸກ 6 ລໍ້', vehicle_type: 'truck',      min_cc: 3001, max_cc: 10000, price: 250_000, detail: 'ກວດກາຄວາມປອດໄພ ແລະ ລະບົບຫ້າມລໍ້',       status: 'active' },
  ].each { |s| center.inspection_services.create!(s) }
end

# ── Insurance Companies ───────────────────────────────────────────────────
[
  { name: 'ບໍລິສັດ ລາວ-ຫວຽດ ປະກັນໄພ',      phone: '021 900111', status: 'active' },
  { name: 'ບໍລິສັດ ກຸງທອງ ປະກັນໄພ (ລາວ)',   phone: '021 900222', status: 'active' },
  { name: 'ບໍລິສັດ ໂຕໂຍຕ້າ ປະກັນໄພ ລາວ',   phone: '021 900333', status: 'active' },
  { name: 'ບໍລິສັດ BCEL ປະກັນໄພ',           phone: '021 900444', status: 'active' },
  { name: 'ບໍລິສັດ ໄຊ ປະກັນໄພ ລາວ',        phone: '021 900555', status: 'active' },
].each do |attrs|
  company = InsuranceCompany.find_or_create_by!(name: attrs[:name]) { |c| c.assign_attributes(attrs) }
  next if company.insurance_packages.exists?
  [
    { name: 'ປະກັນໄພພື້ນຖານ (ລົດຈັກ)',  vehicle_type: 'motorcycle', min_cc: 0,    max_cc: 200,   price: 120_000,  coverage: 'ຄວາມຮັບຜິດຊອບຕໍ່ບຸກຄົນທີ 3', duration_months: 12, status: 'active' },
    { name: 'ປະກັນໄພຄົບວົງຈອນ (ລົດຈັກ)', vehicle_type: 'motorcycle', min_cc: 0,    max_cc: 200,   price: 350_000,  coverage: 'ຄອບຄຸມທຸກຄວາມເສຍຫາຍ',          duration_months: 12, status: 'active' },
    { name: 'ປະກັນໄພພື້ນຖານ (ລົດເກັງ)',   vehicle_type: 'car',        min_cc: 1000, max_cc: 3000,  price: 450_000,  coverage: 'ຄວາມຮັບຜິດຊອບຕໍ່ບຸກຄົນທີ 3', duration_months: 12, status: 'active' },
    { name: 'ປະກັນໄພຄົບວົງຈອນ (ລົດເກັງ)',  vehicle_type: 'car',        min_cc: 1000, max_cc: 3000,  price: 1_200_000, coverage: 'ຄອບຄຸມທຸກຄວາມເສຍຫາຍ',          duration_months: 12, status: 'active' },
    { name: 'ປະກັນໄພລົດບັນທຸກ',           vehicle_type: 'truck',      min_cc: 3001, max_cc: 10000, price: 800_000,  coverage: 'ຄອບຄຸມທຸກຄວາມເສຍຫາຍ',          duration_months: 12, status: 'active' },
  ].each { |p| company.insurance_packages.create!(p) }
end

# ── Service Centers ───────────────────────────────────────────────────────
[
  { name: 'ອູ່ສ້ອມແປງລົດ ໄຊຊະນະ',           location: 'ບ້ານສີຫອມ, ເມືອງຈັນທະບູລີ, ນຄຫຼ',   phone: '020 55123456', owner_name: 'ທ່ານ ໄຊຊະນະ',  service_type: 'garage', rating: 4.5, status: 'active' },
  { name: 'ສູນສ້ອມແປງ ມິດຕະພາບ',             location: 'ບ້ານດົງໂດກ, ເມືອງໄຊທານີ, ນຄຫຼ',    phone: '020 22334455', owner_name: 'ທ່ານ ສົມພອນ',  service_type: 'garage', rating: 4.8, status: 'active' },
  { name: 'ອູ່ສ້ອມແປງດ່ວນ ຫຼັກ 5',           location: 'ບ້ານທົ່ງກາງ, ເມືອງສີສັດຕະນາກ, ນຄຫຼ',phone: '020 99887766', owner_name: 'ທ່ານ ຄຳໃສ',   service_type: 'garage', rating: 4.2, status: 'active' },
  { name: 'ບໍລິການລາກລົດ 24ຊມ ວຽງຈັນ',       location: 'ນະຄອນຫຼວງວຽງຈັນ',                   phone: '020 77665544', owner_name: 'ທ່ານ ບຸນມີ',   service_type: 'towing', rating: 4.6, status: 'active' },
  { name: 'ລາກລົດດ່ວນ ໄຊທານີ',              location: 'ເມືອງໄຊທານີ, ນະຄອນຫຼວງວຽງຈັນ',       phone: '020 11223344', owner_name: 'ທ່ານ ສີດາ',    service_type: 'towing', rating: 4.3, status: 'active' },
  { name: 'ໂຕໂຍຕ້າ ຊ໊ອບ ວຽງຈັນ',            location: 'ທ່າດ່ານ, ເມືອງໄຊເສດຖາ, ນຄຫຼ',       phone: '021 900100',   owner_name: 'Toyota Laos', service_type: 'dealer', rating: 4.9, status: 'active' },
  { name: 'Honda Laos ສູນຈຳໜ່າຍ',            location: 'ບ້ານຮ່ອງຄາຍ, ເມືອງຈັນທະບູລີ, ນຄຫຼ', phone: '021 900200',   owner_name: 'Honda Laos', service_type: 'dealer', rating: 4.7, status: 'active' },
].each do |attrs|
  ServiceCenter.find_or_create_by!(name: attrs[:name]) { |c| c.assign_attributes(attrs) }
end

# ── Vehicle Brands ────────────────────────────────────────────────────────
%w[Toyota Honda Mitsubishi Nissan Mazda Isuzu Ford Hyundai Kia Suzuki
   Subaru BMW Mercedes Audi Volkswagen Volvo Hino Fuso Daihatsu
   Yamaha Kawasaki Ducati Harley-Davidson KTM Bajaj].each do |b|
  VehicleBrand.find_or_create_by!(name: b) { |vb| vb.status = 'active' }
end

sample_users = [
  { first_name: "ສົມພອນ", last_name: "ວົງສະຫວັນ",  gender: "ຊາຍ", date_of_birth: "1990-05-15", phone_number: "020-555-1234", verified: true },
  { first_name: "ຄຳສີ",   last_name: "ພົມມະນີ",    gender: "ຍິງ", date_of_birth: "1985-08-22", phone_number: "030-555-5678", verified: true },
  { first_name: "ດວງດີ",  last_name: "ສຸວັນນະວົງ", gender: "ຊາຍ", date_of_birth: "1992-03-10", phone_number: "021-555-9012", verified: false },
  { first_name: "ສີສຸດ",   last_name: "ຈັນທະພົມ",   gender: "ຍິງ", date_of_birth: "1988-12-05", phone_number: "054-555-3456", verified: true }
]

sample_users.each do |u_attrs|
  User.find_or_create_by!(phone_number: u_attrs[:phone_number]) do |u|
    u.first_name    = u_attrs[:first_name]
    u.last_name     = u_attrs[:last_name]
    u.gender        = u_attrs[:gender]
    u.date_of_birth = u_attrs[:date_of_birth]
    u.verified      = u_attrs[:verified]
  end
end

# ── Plate Types (10 ປະເພດປ້າຍທະບຽນທາງການ ສປປ ລາວ) ─────────────────────────
# ⚠️ ໝາຍເຫດ: ໃນຮູບອ້າງອີງ ລະຫັດ "ພກ" ຖືກໃຊ້ຊ້ຳ 3 ບ່ອນ (#2 ຕ່າງດ້າວ, #3 ລັດ, #8 1%)
#    ແຕ່ plate_code ຕ້ອງບໍ່ຊ້ຳກັນ → ຂ້ອຍໃສ່ລະຫັດຊົ່ວຄາວ "ພກຕ"(#2) ແລະ "ພກ1"(#8).
#    ກະລຸນາແກ້ເປັນລະຫັດຈິງໃນໜ້າ "ຈັດການປ້າຍ" ຖ້າຕ້ອງການ.
[
  { code: 'ຈ2',  name: 'ເອກະຊົນ ສ່ວນຕົວ',        color: 'plate-yellow',         province: true  },
  { code: 'ພກຕ', name: 'ເອກະຊົນຕ່າງດ້າວ',        color: 'plate-yellow-blue',    province: true  }, # temp code
  { code: 'ພກ',  name: 'ລັດບໍລິຫານ',             color: 'plate-blue',           province: true  },
  { code: 'ພ2',  name: 'ບໍລິສັດ / ທຸລະກິດ 100%', color: 'plate-white',          province: true  },
  { code: 'ປກສ', name: 'ປກສ / ຕຳຫຼວດ',           color: 'plate-red-underline',  province: false },
  { code: 'ຂຕ',  name: 'ຕ່າງປະເທດ (ອົງກອນ)',      color: 'plate-white-darkblue', province: false },
  { code: 'ກຫ',  name: 'ກອງທັບ',                 color: 'plate-red',            province: false },
  { code: 'ພກ1', name: 'ບໍລິສັດ / ທຸລະກິດ 1%',   color: 'plate-white-1percent', province: true  }, # temp code
  { code: 'ສກ',  name: 'ສະຖານທູດ',               color: 'plate-diplomat',       province: false },
  { code: 'ສປຂ', name: 'ອົງການ ສະຫະປະຊາຊາດ',      color: 'plate-white-foreign',  province: false },
].each_with_index do |a, i|
  pt = PlateType.find_or_initialize_by(plate_code: a[:code])
  pt.assign_attributes(
    name:          a[:name],
    color_class:   a[:color],
    show_province: a[:province],
    status:        'active',
    position:      i
  )
  pt.save!
end