/*Include required header files*/
// #include <iostream>
#include "file_manager.h"
#include "errors.h"
// #include <cstring>

#include "constants.h"
// #include <vector>
// #include <fstream>
// #include <sstream>
// #include <cmath>
// #include <utility>
#include <bits/stdc++.h>

using namespace std;

FileManager fm;


// Creating only one type of nodes of simplicity
class RNode{
  public:
	int id;                                      //  to get node of rtree
	int parentId;                                // parent of the node
	int dim;                                     // dimension of the point in the node
	int maxCap;                                  // maximum children that can be present in the node
	int NoOfChildPresent;                        // no. of children that will be present in the node
	int isleaf;                                  // tell whether given node is leaf or not
	vector<pair<int,int>> mbr;                   // mbr of node
	vector<int> childId;                         // id of children
	vector<vector<pair<int,int>>> childMbr;      // mbr of the children
  RNode(){

  }
};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// making leafnode of rtree
// makeLeafNode(pagnum,dim,maxCap,mcaPoint,maxCap)
RNode *makeLeafNode(RNode *rnode, int pagnum, int dim, int maxCap, vector<vector<int>>& mcaPoint,int NoOfChildPresent)
{


	rnode->id = pagnum;

	vector<pair<int,int>> mbr;
	int i,j,k,u,v,x,y;

	int int_max = INT_MAX;
	int int_min = INT_MIN;

	rnode->parentId = 0;

	rnode->dim = dim;

	rnode->maxCap = maxCap;

	rnode->NoOfChildPresent = NoOfChildPresent;

	rnode->isleaf = 1;

  rnode->mbr.resize(dim,pair<int,int>({int_max,int_min}));
  rnode->childId.resize(maxCap,-1);
  rnode->childMbr.resize(maxCap,vector<pair<int,int>>(dim,{int_max,int_min}));

	for (i=0;i<NoOfChildPresent;i++)
	{
		for (j=0;j<dim;j++)
		{
			u = mcaPoint[i][j];

			rnode->childMbr[i][j].first = u;
			rnode->childMbr[i][j].second = u;

			if (rnode->mbr[j].first > u)
				rnode->mbr[j].first = u;

			if (rnode->mbr[j].second < u)
				rnode->mbr[j].second = u;
		}
	}

	// cout<<endl;
	// cout<<" printing value in the leaf node :- "<<endl;
	// cout<<" id of rnode - "<<rnode->id<<endl;
	// cout<<" parentId of rnode - "<<rnode->parentId<<endl;
	// cout<<" dim of rnode - "<<rnode->dim<<endl;
	// cout<<" maxCap of rnode - "<<rnode->maxCap<<endl;
	// cout<<" NoOfChildPresent of rnode - "<<rnode->NoOfChildPresent<<endl;
	// cout<<" isleaf of rnode - "<<rnode->isleaf<<endl;

	// cout<<" printing mbr of rnode :-"<<endl;
	// for (i=0;i<rnode->dim;i++)
	// 	cout<<" ( "<<rnode->mbr[i].first<<" , "<<rnode->mbr[i].second<<" ) ";
	// cout<<endl;

	// cout<<" printing childId of rnode :- "<<endl;
	// for (i=0;i<rnode->maxCap;i++)
	// 	cout<<rnode->childId[i]<<" ";
	// cout<<endl;
	// cout<<" printing childMbr of rnode :-"<<endl;

	// for (i=0;i<rnode->maxCap;i++)
	// {
	// 	for (j=0;j<dim;j++)
	// 		cout<<" ( "<<rnode->childMbr[i][j].first<<" , "<<rnode->childMbr[i][j].second<<" ) ";
	// 	cout<<endl;
	// }
	// cout<<endl;
	// cout<<endl;

	return rnode;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// void readFile(FileHandler &fhRtree,int startval, int endval,const int nodesize)
// {
//    cout<<" start of reading of file :- "<<endl;

//    int i,j,k,u,v;

//    RNode *rnode;

//    for (i=startval;i<=endval;i++)
//    {

//    	 PageHandler phRtree = fhRtree.PageAt(i);
//    	 // char *data = phRtree.GetData();
//    	 rnode = (RNode *)phRtree.GetData();

//    	 // memcpy(&rnode, &data[0],sizeof(int)*nodesize);
//    	 cout<<" for node no. "<<i<<endl;
//    	 cout<<endl;
//    	 cout<<" id of node = "<<rnode->id<<endl;
//    	 cout<<" parentid of node = "<<rnode->parentId<<endl;
//    	 cout<<" dim of node = "<<rnode->dim<<endl;
//    	 cout<<" maxCap of node = "<<rnode->maxCap<<endl;
//    	 cout<<" NoOfChildPresent of node = "<<rnode->NoOfChildPresent<<endl;
//    	 cout<<" isleaf of node = "<<rnode->isleaf<<endl;
//    	 cout<<" mbr of node = "<<endl;
//    	 for (j=0;j<rnode->dim;j++)
//    	 	cout<<" ("<<rnode->mbr[j].first<<" , "<<rnode->mbr[j].second<<" ) ";
//    	 cout<<endl;
//    	 cout<<" childId of node = "<<endl;
//    	 for (j=0;j<rnode->maxCap;j++)
//    	 	cout<<rnode->childId[j]<<" ";
//    	 cout<<endl;
//    	 cout<<" childMbr of rnode = "<<endl;
//    	 for (j=0;j<rnode->maxCap;j++)
//    	 {
//    	 	for (k=0;k<rnode->dim;k++)
//    	 		cout<<" ( "<<rnode->childMbr[j][k].first<<" , "<<rnode->childMbr[j][k].second<<" ) ";
//    	 	cout<<endl;
//    	 }
//    	 cout<<endl;
//    	 cout<<endl;

//    	 fhRtree.UnpinPage(i); ///     Change in code
//    	 fhRtree.FlushPage(i); ///     Change in code
//    }

//    cout<<endl;
// }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// makeSimpleNode(pagnum,dim,maxCap,childId,childMbr,maxCap)
// making simple node
// of rTree
void makeSimpleNode(RNode *rnode, int pagnum,int dim, int maxCap, vector<int>& childId,vector<vector<pair<int,int>>>& childMbr,int NoOfChildPresent)
{
	// RNode *rnode = new RNode();

	rnode->id = pagnum;

	rnode->parentId = 0;

	rnode->dim = dim;

	rnode->maxCap = maxCap;

	rnode->NoOfChildPresent = NoOfChildPresent;

	rnode->isleaf = 0;

	int i,j,k,u,v,x,y,z;

	int int_max = INT_MAX;
	int int_min = INT_MIN;

	rnode->mbr.resize(dim,pair<int,int>({int_max,int_min}));
	rnode->childId.resize(maxCap,-1);
	rnode->childMbr.resize(maxCap,vector<pair<int,int>>(dim,{int_max,int_min}));

	for (i=0;i<NoOfChildPresent;i++)
	{
		k = childId[i];
		rnode->childId[i]=k;

		for (j=0;j<dim;j++)
		{
			u = childMbr[i][j].first;
			v = childMbr[i][j].second;

			rnode->childMbr[i][j].first = u;
			rnode->childMbr[i][j].second = v;

			if (rnode->mbr[j].first > u)
				rnode->mbr[j].first = u;

			if (rnode->mbr[j].second < v)
				rnode->mbr[j].second = v;
		}
	}

	// cout<<endl;
	// cout<<" printing value in the simple node :- "<<endl;
	// cout<<" id of rnode - "<<rnode->id<<endl;
	// cout<<" parentId of rnode - "<<rnode->parentId<<endl;
	// cout<<" dim of rnode - "<<rnode->dim<<endl;
	// cout<<" maxCap of rnode - "<<rnode->maxCap<<endl;
	// cout<<" NoOfChildPresent of rnode - "<<rnode->NoOfChildPresent<<endl;
	// cout<<" isleaf of rnode - "<<rnode->isleaf<<endl;

	// cout<<" printing mbr of rnode :-"<<endl;
	// for (i=0;i<rnode->dim;i++)
	// 	cout<<" ( "<<rnode->mbr[i].first<<" , "<<rnode->mbr[i].second<<" ) ";
	// cout<<endl;

	// cout<<" printing childId of rnode :- "<<endl;
	// for (i=0;i<rnode->maxCap;i++)
	// 	cout<<rnode->childId[i]<<" ";
	// cout<<endl;
	// cout<<" printing childMbr of rnode :-"<<endl;

	// for (i=0;i<rnode->maxCap;i++)
	// {
	// 	for (j=0;j<dim;j++)
	// 		cout<<" ( "<<rnode->childMbr[i][j].first<<" , "<<rnode->childMbr[i][j].second<<" ) ";
	// 	cout<<endl;
	// }
	// cout<<endl;
	// cout<<endl;



	// return rnode;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// void printValueOfRnode(RNode *rnode)
// {
// 	cout<<endl;
// 	cout<<" value in node :-"<<endl;
// 	cout<<" id of node :- "<<rnode->id<<endl;
// 	cout<<" parentit of rnode :- "<<rnode->parentId<<endl;
// 	cout<<" dim of rnode :- "<<rnode->dim<<endl;
// 	cout<<" maxCap of rnode :- "<<rnode->maxCap<<endl;
// 	cout<<" NoOfChildPresent of rnode :- "<<rnode->NoOfChildPresent<<endl;
// 	cout<<" isleaf of rnode :- "<<rnode->isleaf<<endl;

// 	vector<pair<int,int>> wrmbr;
// 	vector<int> wrchildId;
// 	vector<vector<pair<int,int>>> wrchildMbr;

// 	cout<<endl;
// 	cout<<" mbr of rnode :- "<<endl;
// 	wrmbr = rnode->mbr;
// 	for (int i=0;i<wrmbr.size();i++)
// 		cout<<" ( "<<wrmbr[i].first<<" , "<<wrmbr[i].second<<" ) ";
// 	cout<<endl;

// 	cout<<endl;
// 	cout<<" childid of node :- "<<endl;
// 	wrchildId = rnode->childId;

// 	for (int i=0;i<wrchildId.size();i++)
// 		cout<<wrchildId[i]<<" ";
// 	cout<<endl;

// 	cout<<endl;
// 	cout<<" mbr of all the children "<<endl;
// 	wrchildMbr = rnode->childMbr;

// 	for (int i=0;i<wrchildMbr.size();i++)
// 	{
// 		for (int j=0;j<wrchildMbr[i].size();j++)
// 			cout<<" ( "<<wrchildMbr[i][j].first<<" , "<<wrchildMbr[i][j].second<<" ) ";
// 		cout<<endl;
// 	}
// 	cout<<endl;
// 	cout<<endl;
// }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void assignParents(FileHandler &fhRtree,int dim,int maxCap,int startval,int endval,const int nodesize)
{
	// cout<<endl;
	// cout<<"------------------------------------------------------------------------------------"<<endl;
	// cout<<" assignParents function "<<endl;
	// cout<<" startval = "<<startval<<endl;
	// cout<<" endval = "<<endval<<endl;

	if (startval == endval)
		return;

	int i,j,k,u,v,x,y,z;

	int totalPages = endval-startval+1;
	int noOfNodes = ceil(float(totalPages)/maxCap);  // be careful to use this value

	// cout<<" totalPages = "<<totalPages<<endl;
	// cout<<" noOfNodes = "<<noOfNodes<<endl;

	int nodeCnt = 0;
	int pagecnt = 0;
	int parentId;

	int startNextPage = 0;
	int endNextPage = 0;

	vector<vector<pair<int,int>>> childMbr;
	vector<int> childId;
	vector<pair<int,int>> tempchildMbr;

	vector<int> vpnum;

	for (i=startval;i<=endval;i++)
	{
		vpnum.push_back(i);

		pagecnt++;

		if (pagecnt!=0 && (pagecnt%maxCap)==0)
		{
			cout<<endl;
			// cout<<" pagecnt in assignParents = "<<pagecnt<<endl;

			PageHandler pwrite = fhRtree.NewPage();
			int pagnum = pwrite.GetPageNum();
			char *dataToWrite = pwrite.GetData();


			for (j=0;j<vpnum.size();j++)
			{
				PageHandler pread = fhRtree.PageAt(vpnum[j]);
				// char *dataToRead = pread.GetData();

				// RNode rnode1;
				RNode *rnode1 = (RNode *)pread.GetData();

				// memcpy(&rnode1,&dataToRead[0],sizeof(int) * nodesize); ///     Change in code

				rnode1->parentId = pagnum;

				//prnt about node
				// cout<<"for j = "<<j<<endl;
			
				cout<<endl;

				childId.push_back(rnode1->id);
				childMbr.push_back(rnode1->mbr);

				// rnode1->parentId = parentId;

				// memcpy(&dataToRead[1],&parentId,sizeof(int)); ///     Change in code

				fhRtree.MarkDirty(vpnum[j]);
				fhRtree.UnpinPage(vpnum[j]);
				fhRtree.FlushPage(vpnum[j]);
			}

			RNode *rnode2 = new RNode();
            makeSimpleNode(rnode2, pagnum,dim,maxCap,childId,childMbr,maxCap);
			memcpy(dataToWrite, rnode2, nodesize);  ///     Change in code

			fhRtree.MarkDirty(pagnum);
			fhRtree.UnpinPage(pagnum);
			fhRtree.FlushPage(pagnum);



			vpnum.clear();
			childId.clear();
			childMbr.clear();

			if (nodeCnt==0)
				startNextPage = pagnum;

			nodeCnt++;

			if (nodeCnt==noOfNodes)
				endNextPage = pagnum;

			// cout<<endl;
		}
	}

	if (vpnum.size()!=0)
	{
		int noofpoints = vpnum.size();

		PageHandler pwrite = fhRtree.NewPage();
		int pagnum = pwrite.GetPageNum();
		char *dataToWrite = pwrite.GetData();

		for (j=0;j<vpnum.size();j++)
		{
			
			PageHandler pread = fhRtree.PageAt(vpnum[j]);
			// char *dataToRead = pread.GetData();

			parentId = pagnum;
			RNode *rnode1 = (RNode *)pread.GetData();
			
			rnode1->parentId = parentId;

			// RNode rnode1;
			// memcpy(&rnode1,&dataToRead[0],sizeof(int) * nodesize); ///     Change in code
			// parentId = pagnum;

			
			childId.push_back(rnode1->id);
			
			childMbr.push_back(rnode1->mbr);
			

			// memcpy(&dataToRead[1],&parentId,sizeof(int)); ///     Change in code
			
			fhRtree.MarkDirty(vpnum[j]);
		
			fhRtree.UnpinPage(vpnum[j]);
			
			fhRtree.FlushPage(vpnum[j]);
		


		}

		RNode *rnode2 = new RNode();
        makeSimpleNode(rnode2, pagnum,dim,maxCap,childId,childMbr,noofpoints);
		memcpy(dataToWrite, rnode2, nodesize); ///     Change in code

		fhRtree.MarkDirty(pagnum);
		fhRtree.UnpinPage(pagnum);
		fhRtree.FlushPage(pagnum);

		vpnum.clear();
		childId.clear();
		childMbr.clear();

		if (nodeCnt==0)
			startNextPage = pagnum;

		nodeCnt++;

		if (nodeCnt==noOfNodes)
			endNextPage = pagnum;

	}

	// cout<<endl;
	// cout<<" obtained startNextPage = "<<startNextPage<<endl;
	// cout<<" obtained endNextPage = "<<endNextPage<<endl;
	// cout<<endl;

	if (startNextPage !=endNextPage)
	{
		assignParents(fhRtree,dim,maxCap,startNextPage,endNextPage,nodesize); ///     Change in code
	}
	else
	{
		// cout<<endl;
		// cout<<" rtree is made by bulk load "<<endl;
		// cout<<endl;
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*define auxiliary functions  for buld loading of the data*/
void bulkLoadHandler(string bulkloadFile, int numPoints, int maxCap,int dim ,int cond, int stId, int endId)
{
	if (cond==0)
	{
		if (stId == -1 && endId == -1)
		{
			// cout<<"BulkloadFile:"<<bulkloadFile<<" NumPoints:"<<numPoints<<endl;

			FileHandler fh = fm.OpenFile (bulkloadFile.c_str());

			int noOfPages = ceil(float(numPoints * dim * sizeof(int) ) / PAGE_CONTENT_SIZE);  // be careful
			float pointSize = dim * sizeof(int);
			int numberofPointPerPage = floor( float(PAGE_CONTENT_SIZE) / pointSize); // be careful
			int noOfNodes = ceil(float(numPoints) /maxCap);  // be careful

			const int nodesize = sizeof(RNode); ///     Change in code

			// cout<<endl;
			// cout<<" no of pages == "<<noOfPages<<endl;
			// cout<<" pointSize = "<<pointSize<<endl;
			// cout<<" number of point per page = "<<numberofPointPerPage<<endl;
			// cout<<" no of nodes = "<<noOfNodes<<endl;
			// cout<<" node size in size of int = "<<nodesize<<endl;
			// cout<<endl;

			FileHandler fhRtree = fm.CreateFile("rtreeStore.txt");

			int i,j,k,m,u,v,x,y;

			vector<int> point;
			vector<vector<int>> mcaPoint;
			int num;
			int totalNum = 0;
			int dNumcnt = 0;
			int nodeCnt = 0;
			int cond1 = 0;
			int cond2 = 0;
			int isize = sizeof(int);
			// cout<<endl;

			int startval = 0;
			int endval = 0;

			for (i=0;i<noOfPages;i++)
			{
				PageHandler ph = fh.PageAt(i);
				char *data = ph.GetData();

				for (j=0;j<numberofPointPerPage;j++)
				{
					memcpy(&num, &data[(j * isize)], sizeof(int));
          // cout<<num<<" ";
					point.push_back(num);
					totalNum++;

					if ((totalNum%dim)==0)
					{
						// cout<<"point no. "<<dNumcnt<<endl;

						// for (k=0;k<point.size();k++)
						// 	cout<<point[k]<<" ";
						// cout<<endl;
						// cout<<endl;

						mcaPoint.push_back(point);

						point.clear();

						dNumcnt++;

						if ((dNumcnt%maxCap)==0)
						{
							// cout<<" node no. "<<nodeCnt<<endl;

							// for (k=0;k<mcaPoint.size();k++)
							// {
							// 	for (m=0;m<mcaPoint[k].size();m++)
							// 		cout<<mcaPoint[k][m]<<" ";
							// 	cout<<endl;
							// }
							// cout<<endl;

							PageHandler phRtree = fhRtree.NewPage();
							int pagnum = phRtree.GetPageNum();

							// cout<<" pagnum = "<<pagnum<<endl;
							// cout<<endl;

							if (nodeCnt==0)
								startval = pagnum;

							// char *dataToWrite = phRtree.GetData();
							// RNode rnode = makeLeafNode(pagnum,dim,maxCap,mcaPoint,maxCap);
							// memcpy(&dataToWrite[0],&rnode,nodesize);   ///     Change in code

							// Changed Code
							RNode *rwrite = (RNode *)phRtree.GetData();
							makeLeafNode(rwrite, pagnum,dim,maxCap,mcaPoint,maxCap);

							fhRtree.MarkDirty(pagnum);
							fhRtree.UnpinPage(pagnum);
							fhRtree.FlushPage(pagnum);


							PageHandler ptest = fhRtree.PageAt(pagnum);
							RNode *rtest = (RNode *)ptest.GetData();

							// cout<<" printing the value of node after writing in the file :- "<<endl;
							// cout<<" id of rtest :- "<<rtest->id<<endl;
							// cout<<" parentId of rtest :- "<<rtest->parentId<<endl;
							// cout<<" dim of rtest :- "<<rtest->dim<<endl;
							// cout<<" maxCap of rtest :- "<<rtest->maxCap<<endl;
							// cout<<" NoOfChildPresent of rtest :- "<<rtest->NoOfChildPresent<<endl;
							// cout<<" isleaf of rtest :- "<<rtest->isleaf<<endl;
							// cout<<" mbr of the leaf :- "<<endl;
							// for (u=0;u<rtest->dim;u++)
							// 	cout<<" ( "<<rtest->mbr[u].first<<" , "<<rtest->mbr[u].second<<" ) ";
							// cout<<endl;
							// cout<<" childId of thr rtest :- "<<endl;
							// for (u=0;u<rtest->maxCap;u++)
							// 	cout<<rtest->childId[u]<<" ";
							// cout<<endl;
							// cout<<" childmbr of the rtest :- "<<endl;
							// for (u=0;u<rtest->maxCap;u++)
							// {
							// 	for (v=0;v<rtest->dim;v++)
							// 		cout<<" ( "<<rtest->childMbr[u][v].first<<" , "<<rtest->childMbr[u][v].second<<" ) ";
							// 	cout<<endl;
							// }
							// cout<<endl;
							// cout<<endl;

							fhRtree.MarkDirty(pagnum);
							fhRtree.UnpinPage(pagnum);
							fhRtree.FlushPage(pagnum);

							nodeCnt++;

							mcaPoint.clear();

							if (nodeCnt==noOfNodes)
							{

								endval = pagnum;
							}

						}
					}

					if (dNumcnt==numPoints || totalNum==(dim*numPoints) || (nodeCnt==noOfNodes))
					{
						cond1=1;
						break;
					}
				}

				if (mcaPoint.size()!=0)
				{
					// cout<<" node no. "<<nodeCnt<<endl;

					// for (k=0;k<mcaPoint.size();k++)
					// {
					// 	for (m=0;m<mcaPoint[k].size();m++)
					// 		cout<<mcaPoint[k][m]<<" ";
					// 	cout<<endl;
					// }
					// cout<<endl;

					int leftPoints = mcaPoint.size();

					PageHandler phRtree = fhRtree.NewPage();
					int pagnum = phRtree.GetPageNum();

					// cout<<" pagnum = "<<pagnum<<endl;
					// cout<<endl;

					// char *dataToWrite = phRtree.GetData();
					// RNode rnode = makeLeafNode(pagnum,dim,maxCap,mcaPoint,leftPoints);
					// memcpy(&dataToWrite[0],&rnode, nodesize);  ///     Change in code

					RNode *rwrite = (RNode *)phRtree.GetData();
          // RNode *rleaf = new RNode();
					makeLeafNode(rwrite, pagnum,dim,maxCap,mcaPoint,leftPoints);
					// rwrite = rleaf;

					fhRtree.MarkDirty(pagnum);
					fhRtree.UnpinPage(pagnum);
					fhRtree.FlushPage(pagnum);

					if (nodeCnt==0)
			            startval = pagnum;

					nodeCnt++;

					if (nodeCnt == noOfNodes)
					{

						endval = pagnum;
					}

					mcaPoint.clear();
				}

				if (cond1==1)
					break;
			}

			// cout<<endl;
			// cout<<endl;
			// cout<<" endval = "<<endval<<endl;
			// cout<<" startval = "<<startval<<endl;
			// cout<<endl;
			// cout<<endl;

			// cout<<" reading file ----> "<<endl;
			// reading file data

			// cout<<endl;
			// cout<<endl;
			// cout<<" endval = "<<endval<<endl;
			// cout<<" heloo"<<endl;
			// cout<<" startval = "<<startval<<endl;
			// cout<<endl;
			// cout<<endl;

			if (startval != endval)
			{
				assignParents(fhRtree,dim,maxCap,startval,endval,nodesize);  ///     Change in code
			}
			else
			{
				// cout<<endl;
				// cout<<"done work"<<endl;
				// cout<<endl;
			}

			PageHandler pgstart = fhRtree.FirstPage();
			int pagst = pgstart.GetPageNum();
			PageHandler pgend = fhRtree.LastPage();
			int pagend = pgend.GetPageNum();

			// cout<<endl;
			// cout<<" total number of pages in file :- "<<(pagend-pagst+1)<<endl;
			// cout<<endl;

			fm.CloseFile(fh);
			fm.CloseFile(fhRtree);
		}
		else
		{
			// cout<<" Not written "<<endl;
		}
	}
	else
	{
		// cout<<" NOt written "<<endl;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

bool matchPoint(vector<pair<int,int>> &cmbr,vector<int> &point,int dim)
{
	int i,j,k,u,v,x,y;

	for (i=0;i<dim;i++)
	{
		u = cmbr[i].first;
		v = cmbr[i].second;

		x = point[i];

		if (!(u==x && x==v))
			return false;
	}
	return true;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

bool checkPointForChild(vector<pair<int,int>> &cmbr,vector<int> &point,int dim)
{
	int i,j,k,u,v,x,y;

	for (i=0;i<dim;i++)
	{
		u = cmbr[i].first;
		v = cmbr[i].second;

		x = point[i];

		if (!(u<=x && x<=v))
			return false;
	}
	return true;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool checkPointInSpace(vector<pair<int,int>> &rmbr,vector<int> &point,int dim)
{
	int i,j,k,u,v,x,y;

	for (i=0;i<dim;i++)
	{
		u = rmbr[i].first;
		v = rmbr[i].second;

		x = point[i];

		if (!(u<=x && x<=v))
			return false;
	}
	return true;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////


bool queryHandler(FileHandler &fhRtree,int pagnum,vector<int> &point,int maxCap,int dim)
{
	RNode *rnode;

	PageHandler phRtree = fhRtree.PageAt(pagnum);

	rnode = (RNode *)phRtree.GetData();

	int i,j,k,u,v,x,y,z;
	int totalchild;
	vector<pair<int,int>> rmbr,cmbr;

	rmbr = rnode->mbr;
	totalchild = rnode->NoOfChildPresent;
	int cid;


	if ((rnode->isleaf)==1)
	{
		for (i=0;i<totalchild;i++)
		{
			cmbr = rnode->childMbr[i];

			if (matchPoint(cmbr,point,dim))
				return true;
		}
		return false;
	}
	else
	{
		if (checkPointInSpace(rmbr,point,dim))
		{
			bool cond;

			for (i=0;i<totalchild;i++)
			{
				cmbr = rnode->childMbr[i];
				cid = rnode->childId[i];

				if (cid!=-1 && checkPointForChild(cmbr,point,dim))
				{
					if(queryHandler(fhRtree,cid,point,maxCap,dim))
						return true;
				}
			}
			return false;
		}
		else
			return false;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


void insertHandler(vector<int> & point, int maxCap,int dimensionality){

}
/* end of definition of auxiliary functions*/



/* definition of main() function start here */
int main( int argc, char *argv[])
 {
	if (argc < 5)
	{ // We expect 5 arguments: rtree query.txt maxCap dimensionality output.txt

        cout<<"Kindly provide correct command line arguments."<<endl;
        std::cerr << "Usage: " << argv[0] << " query.txt maxCap dimensionality output.txt" << endl;
        return 1;
    }

    //initialize variables
    string queryTxtFile = "";
	int maxCap = 0;
	int dimensionality = 0;
	string outPutTxtFile = "";


	queryTxtFile = argv[1];
	maxCap = stoi(argv[2]);
	dimensionality = stoi(argv[3]);
	outPutTxtFile = argv[4];
	cout<<"\n Provided command line arguments are:"<<endl;
	cout<<" QueryTxtFile: "<<queryTxtFile<<endl;
	cout<<" MaxCap: "<<maxCap<<endl;
	cout<<" Dimensionality: "<<dimensionality<<endl;
	cout<<" OutPutTxtFile: "<<outPutTxtFile<<endl;

	fstream queryFile, outFile;
	//open the query file for input operations
	queryFile.open(queryTxtFile, ios::in);

	//create and open the output file for output operations
	outFile.open(outPutTxtFile, ios::out);

	string lineStr;

	if(queryFile.is_open() && outFile.is_open())
	{

		int p=0,q=0,r=0;
		//Read contents line by line from query text file
		while (getline(queryFile,lineStr))
		{
      		//cout << lineStr << '\n';

      		vector<string> row;
			istringstream iss(lineStr);

			for(string lineStr; iss >> lineStr; )
			{
    			row.push_back(lineStr);
			}

			if(row[0]=="BULKLOAD")
			{

				string bulkloadFile = row[1];
				int numPoints = stoi(row[2]);
				int cond = 0;
				int stId = -1;
				int endId = -1;

				// calling BulkLoaderFunction with given value
				bulkLoadHandler(bulkloadFile, numPoints,maxCap,dimensionality,cond,stId,endId);

				outFile<<"BULKLOAD\n\n";
				p++;

			}
			else if(row[0]=="INSERT")
			{

				vector<int> point;
				for(int i=1; i<row.size(); i++){
					point.push_back(stoi(row[i]));
				}

				insertHandler(point,maxCap,dimensionality);

				outFile<<"INSERT\n\n";
				q++;
			}
			else if(row[0]=="QUERY")
			{

				vector<int> point;
				for(int i=1; i<row.size(); i++){
					point.push_back(stoi(row[i]));
				}

				FileHandler fhRtree = fm.OpenFile("rtreeStore.txt");
				PageHandler plast = fhRtree.LastPage();
				int pagnum = plast.GetPageNum();

				if (point.size()!=dimensionality)
				{
					// cout<<endl;
					// cout<<" case 1 - false "<<endl;
					// cout<<endl;
					outFile<<"FALSE\n\n";
				}
				else if(queryHandler(fhRtree,pagnum,point,maxCap,dimensionality) == true)
				{
					// cout<<endl;
					// cout<<" case 2 - true "<<endl;
					// cout<<endl;

					outFile<<"TRUE\n\n";
				}
				else
				{
					// cout<<endl;
					// cout<<" case 3 - false "<<endl;
					

					outFile<<"FALSE\n\n";
				}

				fm.CloseFile(fhRtree);

				r++;
			}
    	}

    	cout<<"Number of BulkloadFile:"<<p<<" Insert:"<<q<<" Query:"<<r<<endl;
    	//close the query file and output file
    	queryFile.close();
    	outFile.close();
    	fm.DestroyFile("rtreeStore.txt");
	}
	else
	{
		cout<<"Unable to open query text file or create output file."<<endl;
	}

	return 0;

}
