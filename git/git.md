1.安装git:

命令包：sudo apt update git

Brew update git

Scoop update git

2.进行命令配置，确定名字和邮箱，一旦使用—glabal，代表所有的仓库全部采用

\$ git config --global user.name "Your Name"

\$ git config --global user.email <email@example.com>

3.创建仓库

\$ mkdir learngit

\$ cd learngit

\$ pwd 用于显示再当前目录

\$ git init 变成可以采用git管理的仓库

4.添加文件

\$ git add readme.txt 可以多次添加文件到缓冲区

\$ git commit -m "wrote a readme file"
进行提交，但是提交是一次性把所有的文件进行提交，-m后面是对本次提交的说明

5.1命令

查看状态，是否进行修改过：\$ git status

查看修改前后的内容变化：\$ git diff readme.txt

5.2版本回退

\$ git log
--pretty=oneline，用于显示历史记录，后面的参数用于简化输出信息

版本回退：\$ git reset --hard HEAD^
上个版本是HEAD^，上上个是HEAD^^，往上一百个版本是HEAD~100

--hard是回退到上个版本的已提交状态，--soft是回退到这个版本的已添加未提交状态，--mixed是回退到这个版本未添加状态

\$ git reset --hard 版本号 可以回到版本号对应的版本，忘记版本号\$ git
reflog

Cat 文件名 可以用于显示文件的内容

5.3撤销修改

再没有提交的时候进行的修改使用\$ git checkout -- readme.txt
放弃工作区的修改，两种情况，一种是修改后还没放到暂存区回到和版本库一样的状态，提交到暂存区后修改回到提交到暂存区后的状态，

若已经提交到暂存区，使用git reset HEAD
\<file\>可以把暂存区的修改撤销掉，get
reset不仅可以回退版本也可以将暂存区的修改回退到工作区，

若已经提交并且commit则直接回退版本

5.4删除文件

\$ git rm test.txt 先删除文件，然后再git
commit提交文件，版本库删除，确保版本库和工作区一致。

如果删错了可以用\$ git checkout --
test.txt，可以将版本库中的文件替换工作区中的文件

6添加远程库

先在github上创建一个仓库，再在本地\$ git remote add origin 仓库链接
进行连接推送，远程库名字就叫origin

再进行\$ git push -u origin
master，把本地库中的所有内容全部推送到远程库上，-u会将本地的master分支和远程的master分支连接起来

之后再次进行新的内容推送：\$ git push origin master

6.1删除远程库

先使用\$ git remote -v 查看远程库

再使用git remote rm
\<name\>进行删除，这里只是删除了与远程库的连接，删除远程库还需要去GitHub

6.2克隆仓库

\$ git clone ssh链接

7.1分支

查看分支：git branch

创建分支：git branch \<name\>

切换分支：git checkout \<name\>或者git switch \<name\>

创建+切换分支：git checkout -b \<name\>或者git switch -c \<name\>

合并某分支到当前分支：git merge \<name\>

删除分支：git branch -d \<name\>

7.2在创建分支的时候如果在一个分支上进行提交但是切换到另一个的时候也进行了提交，此时合并会发生冲突此时git
status会显示冲突的文件

使用cat命令查看内容并进行更改再进行提交

\$ git log --graph --pretty=oneline --abbrev-commit
可以查看合并的情况，分支合并图，最后删除另一个分支

7.3分支管理

合并分支时，加上--no-ff参数就可以用普通模式合并，合并后的历史有分支，能看出来曾经做过合并，而fast
forward合并就看不出来曾经做过合并。

7.4bug分支

\$ git stash
可以用于把当前现场进行保存，此时就可以进行其他bug修复，修复完成以后再继续

\$ git stash pop 可以用于恢复现场然后同时把stash的内容删除

git stash apply可以用于恢复现场，但是恢复后，stash内容并不删除

\$ git stash list 可以用于stash保存的所有内容的查看

\$ git stash apply stash@{0}
多次stash后，可以使用该命令将对应的stash恢复

在主分支上做出的修改在其他分支上只需要切换到其他分支然后\$ git
cherry-pick
《主分支提交commit的码》就可以，在分支上修改合并到主分支上需要先git
stash再进行git cherry-pick

7.5feature分支

每次开发一个新功能就需要新建一个分支，丢弃一个没有被和并过的分支可以使用git
branch -D \<name\>强行删除

7.6多人协作

查看远程库时：\$ git remote -v

推送分支：把该分支上的所有本地推送到远程库中，推送时要制定本地分支，

\$ git push origin master，最后一位指定不同的分支

其他人要从远程库上进行clone时，默认只能看到master分支，若是开发其他分支则必须创建远程origin的分支到本地，

\$ git checkout -b dev origin/dev

此后再开发就可以将其他分支推送到远程库，先提交再commit，再\$ git push
origin \<branch-name\>

当推送出现冲突时，先git
pull把最新提交拉下来，再在本地合并，在进行推送，若本地git pull
也失败，则需要先建立连接\$ git branch --set-upstream-to=origin/dev
dev，再进行pull，解决后再push

git pull把最新的提交从origin/dev抓下来

8.1创建标签

首先切换到需要打标签的分支上，再使用\$ git tag
v1.0，可以打上一个新标签，\$ git tag可以查看所有的标签，

若是对历史的commit进行打标签，先找到历史提交的commit id： \$ git log
--pretty=oneline --abbrev-commit

再使用\$ git tag v0.9 \<commit id\>对对应的提交进行打标签

\$ git show v0.9
可以查看对应的标签信息，还可以创建带有说明的标签，用-a指定标签名，-m指定说明文字：git
tag -a \<tagname\> -m "blablabla..."可以指定标签信息

8.2操作标签

git push origin \<tagname\>可以推送一个本地标签；

git push origin --tags可以推送全部未推送过的本地标签；

git tag -d \<tagname\>可以删除一个本地标签；

git push origin :refs/tags/\<tagname\>可以删除一个远程标签。
