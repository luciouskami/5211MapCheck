local function main()
	
	--������ arg[1]Ϊ��ͼ, arg[2]Ϊ����·��
	if (not arg) or (#arg < 2) then
		print('[����]: �뽫��ͼ�϶���check.bat�Ͻ��м���')
	end
	
	local input_map  = arg[1]
	local root_dir   = arg[2]
	
	--���require��Ѱ·��
	package.path = package.path .. ';' .. root_dir .. 'src\\?.lua'
	package.cpath = package.cpath .. ';' .. root_dir .. 'build\\?.dll'
	require 'luabind'
	require 'filesystem'
	require 'utility'

	--����·��
	local input_map    = fs.path(input_map)
	local root_dir     = fs.path(root_dir)

	--��ͼ��
	local map_name = input_map:filename():string():sub(1, -5)
	
	local test_dir     = root_dir / 'test'
	local log_dir      = root_dir / 'log' / os.date('%Y.%m.%d')
	local map_log_dir  = log_dir / ('[' .. os.date('%H.%M.%S') .. ']' .. map_name .. '.txt')

	fs.remove_all(test_dir)
	fs.create_directories(test_dir)

	fs.create_directories(log_dir)

	--����log
	local f_log = io.open(map_log_dir:string(), 'w')
	
	local oldprint = print
	
	function print(...)
		f_log:write(('[%.3f]%s\n'):format(os.clock(), table.concat({...}, '%t')))
		return oldprint(...)
	end
	
	print('[��ͼ]: ' .. map_name)

	--У���ļ���
		--����ļ�������
		if #map_name > 27 then
			print('[����]: �ļ�������,���ܴ���27���ַ�: ' .. #map_name)
			return
		else
			print('[ͨ��]: �ļ�������Ϊ: ' .. #map_name)
		end

		--����Ƿ�����Ƿ��ַ�
			local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ._0123456789()'
			--��������
			local t = {}
			for i = 1, #chars do
				t[chars:sub(i, i)] = true
			end

			for i = 1, #map_name do
				if not t[map_name:sub(i, i)] then
					print('[����]: �ļ��������Ƿ��ַ�: ' .. map_name:sub(i, i))
					return
				end
			end
			print('[ͨ��]: �ļ�������ʹ��')

	--�򿪵�ͼ
	local inmap = mpq_open(input_map)
	if inmap then
		print('[�ɹ�]: �� ' .. input_map:string())
	else
		print('[����]: �� ' .. input_map:string() .. ' ,��������ͷ?')
		return
	end
	
	--��Ҫ�������ļ�
	local list_file = {
		{'(listfile)', '(listfile)'},
		{'war3map.w3i', 'war3map.w3i'},
		{'scripts\\war3map.j', 'war3map.j'},
		{'war3map.j', 'war3map.j'},
	}

	--������Щ�ļ�
	for _, t in ipairs(list_file) do
		local mpq_name, file_name = t[1], t[2]
		local file_dir = test_dir / file_name
		if inmap:extract(mpq_name, file_dir) then
			print('[�ɹ�]: ���� ' .. mpq_name)
		else
			print('[ʧ��]: ���� ' .. mpq_name)
		end
	end

	--�رյ���ͼ
	inmap:close()

	--��ȡj�ļ���w3i�ļ�
	local f_j = io.open((test_dir / 'war3map.j'):string(), 'r')
	local f_w3i = io.open((test_dir / 'war3map.w3i'):string(), 'rb')
	local j, w3i
	if f_j then
		j = f_j:read('*a')
		f_j:close()
		print('[�ɹ�]: ��j�ļ�')
	else
		print('[����]: û���ҵ�j�ļ�')
		return
	end
	if f_w3i then
		w3i = f_w3i:read('*a')
		f_w3i:close()
		print('[�ɹ�]: ��w3i�ļ�')
	else
		print('[����]: û���ҵ�w3i�ļ�')
		return
	end

	--�������
		--���ע��ű�ʽ����
			local mod = false
			--����޸ĺۼ�(ͨ��listfile)
				local f_listfile = io.open((test_dir / '(listfile)'):string(), 'r')
				if f_listfile then
					local listfile = f_listfile:read('*a')
					f_listfile:close()
					if listfile:match('war3map.j') then
						print('[����]: �����޸ĺۼ�,�����н�һ�����')
						mod = true
					end
				end

			--����޸ĺۼ�(ͨ��������)
				local chars = {'\t', '    ', 'hke_', 'efl_', 'feiba', 'WCDTOF'}
				for _, char in ipairs(chars) do
					if j:match(char) then
						print('[����]: ���ֿ��ɴ���,�����н�һ�����')
						mod = true
						break
					end
				end

			--���н�һ�����
			if mod then
				local ss = {} --��ſ��ɴ���
				for line in io.lines((test_dir / 'war3map.j'):string()) do
					for _, char in ipairs(chars) do
						if line:match(char) then
							table.insert(ss, line)
							break
						end
					end
				end

				local funcs = {
					{'CreateTrigger', '����������'},
					{'CreateTimer', '������ʱ��'},
					{'TimerStart', '������ʱ��'},
					{'StartTimer', '������ʱ��'},
					{'AddItem', '�����Ʒ'},
					{'SetItem', '������Ʒ'},
					{'EventPlayerChatString', '������Ϣ'},
					{'FogMaskEnable', '�������'},
					{'FogEnable', '�������'},
					{'UnitResetCooldown', '������ȴ'},
					{'SetHero', '����Ӣ��'},
					{'SetUnit', '���õ�λ'},
					{'SetPlayer', '�������'},
					{'PlayerState', '�������'},
					{'UnitAddAbility', '��Ӽ���'},
					{'Dialog', '�Ի���'},
					{'TriggerRegister', 'ע�ᴥ����'},
					{'TriggerAdd', 'ע�ᴥ����'},
					{'_GOLD', '��ҽ�Ǯ'},
					{'_LUMBER', '���ľ��'},
					{'_LIFE', '��λ����'},
					{'_MANA', '��λ����'},
				}

				local cheats = setmetatable({}, {__index = function() return 0 end})
				local cheat_count = 0

				for x = 1, #ss do
					local script = ss[x]
					for y = 1, #funcs do
						local word, reason = funcs[y][1], funcs[y][2]
						if script:match(word) then
							cheats[reason] = cheats[reason] + 1
							cheat_count = cheat_count + 1
						end
					end
				end

				if #ss > 0 and cheat_count > 0 then
					local cheat_result = {}
					for name, count in pairs(cheats) do
						table.insert(cheat_result, name .. ': ' .. count)
					end
					print(('[����]: ���ֿ��ɵ����д���\n\t�������: %d\n\t%s\n\t����: %s'):format(#ss, table.concat(cheat_result, '\n\t'), cheat_count))
					return
				else
					print('[ͨ��]: δ���ֿ��ɵ����д���')
				end
			end

		--���InitCustomPlayerSlots,InitCustomTeams,InitAllyPriorities��3�������Ƿ񱻻���
			--�ҵ�ָ��������
			local f_config = j:match("function config takes nothing returns nothing(.-)endfunction")
			--�ȼ���Ƿ��к���
			if (f_config:find('InitCustomPlayerSlots') or f_config:find('SetPlayerRacePreference'))
			and (f_config:find('InitCustomTeams') or f_config:find('SetPlayerTeam'))
			and (f_config:find('InitAllyPriorities') or f_config:find('SetStartLocPrioCount')) then
				print('[ͨ��]: ��config�������ҵ���ָ������')
			else
				print('[����]: config����������')
				return
			end

		--���w3i�ļ���j�ļ��Ķ��������Ƿ�ƥ��
			

	--���
	print('[ͨ��]: ��ʱ ' .. os.clock() .. ' ��')

	return true
	
end

if not main() then
	os.execute('@pause')
end