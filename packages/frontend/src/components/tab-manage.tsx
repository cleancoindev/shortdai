import {
  Box,
  Button,
  FormControl,
  MenuItem,
  Paper,
  Select,
  Typography,
} from "@material-ui/core";
import { ethers } from "ethers";
import useCdps from "../containers/use-cdps";
import useCloseShort from "../containers/use-close-short";
import useProxy from "../containers/use-proxy";
import useSelectedCdp from "../containers/use-selected-cdp";
import useShortDaiState, {
  ShortDaiState,
} from "../containers/use-shortdai-state";
import useUsdc from "../containers/use-usdc";
import { prettyStringDecimals } from "./utils";

const TabManage = () => {
  const {
    closeShortDaiPosition,
    isClosingShort,
  } = useCloseShort.useContainer();
  const { isCreatingProxy, createProxy } = useProxy.useContainer();
  const { isApprovingUsdc, approveUsdc } = useUsdc.useContainer();
  const { shortDaiState } = useShortDaiState.useContainer();
  const { getCdps, isGettingCdps, cdps } = useCdps.useContainer();
  const {
    cdpId,
    isGettingCdpStats,
    cdpStats,
    setCdpId,
  } = useSelectedCdp.useContainer();

  const validCdpId = cdpId !== 0;

  console.log(cdps);

  return <></>;
};

export default TabManage;