import sys

def modify_project_file(file_path, original_name, new_name):
    with open(file_path, 'r', encoding='utf-8') as file:
        lines = file.readlines()

    in_release_group = False

    # 查找并修改内容
    for i, line in enumerate(lines):
        # 修改 TargetName
        if "<TargetName" in line:
            lines[i] = line.replace(original_name, new_name)

        # 修改 InlineFunctionExpansion 和 Optimization
        if "<ItemDefinitionGroup Condition=\"'$(Configuration)|$(Platform)'=='Release|x64'\">" in line:
            in_release_group = True
        elif in_release_group and "</ItemDefinitionGroup>" in line:
            in_release_group = False

        if in_release_group:
            if "<InlineFunctionExpansion>" in line:
                lines[i] = line.replace("AnySuitable", "Disabled") + "\n"
            elif "<Optimization>" in line:
                lines[i] = line.replace("MaxSpeed", "Disabled") + "\n"
            elif "<ProgramDataBaseFile>" in line:
                lines[i] = line.replace(f"{original_name}.pdb", f"{new_name}.pdb") + "\n"

    # 将修改后的内容写回文件
    with open(file_path, 'w', encoding='utf-8') as file:
        file.writelines(lines)

if __name__ == "__main__":
    # 手动赋值文件路径和名称
    files_to_modify = [
        {
            "file_path": "D:/rayvision/remote_desktop/out-screen/raysync_client/RaysyncClient.vcxproj",
            "original_name": "RaysyncClient",
            "new_name": "RayLink"
        },
        {
            "file_path": "D:/rayvision/remote_desktop/out-screen/raysync_service/raysync_service.vcxproj",
            "original_name": "raysync_service",
            "new_name": "RayLinkService"
        },
    ]

    for item in files_to_modify:
        modify_project_file(item["file_path"], item["original_name"], item["new_name"])
        print(f"已修改: {item['file_path']} 从 {item['original_name']} 到 {item['new_name']}")
